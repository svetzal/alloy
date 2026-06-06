//! `alloy intent` — CRUD and lifecycle transitions for engineering intent
//! records, addressed by their project-local slug.

use anyhow::{bail, Result};
use serde_json::{Map, Value};

use crate::api::{Api, IntentRecord, Transition};
use crate::output::{emit_success, or_dash};

/// The intent fields settable on create/update. Each `Some` is written; each
/// `None` is left untouched (on update) or defaulted by the backend (on
/// create). `title` is required on create and enforced by the CLI parser.
#[derive(Debug, Default, Clone)]
pub struct IntentFields {
    pub title: Option<String>,
    pub slug: Option<String>,
    pub capability: Option<String>,
    pub threat: Option<String>,
    pub expectation: Option<String>,
    pub strategy: Option<String>,
    pub evidence_summary: Option<String>,
    pub tradeoff: Option<String>,
    pub status: Option<String>,
    pub confidence: Option<f64>,
}

impl IntentFields {
    /// Builds a JSON body containing only the fields that were supplied.
    fn to_body(&self) -> Value {
        let mut map = Map::new();
        let strings = [
            ("title", &self.title),
            ("slug", &self.slug),
            ("capability", &self.capability),
            ("threat", &self.threat),
            ("expectation", &self.expectation),
            ("strategy", &self.strategy),
            ("evidence_summary", &self.evidence_summary),
            ("tradeoff", &self.tradeoff),
            ("status", &self.status),
        ];
        for (key, value) in strings {
            if let Some(v) = value {
                map.insert(key.to_string(), Value::String(v.clone()));
            }
        }
        if let Some(c) = self.confidence {
            if let Some(n) = serde_json::Number::from_f64(c) {
                map.insert("confidence".to_string(), Value::Number(n));
            }
        }
        Value::Object(map)
    }

    fn any_update_field(&self) -> bool {
        self.to_body()
            .as_object()
            .is_some_and(|m| m.keys().any(|k| k != "slug"))
    }
}

/// `alloy intent list`.
pub fn list(api: &dyn Api, json: bool) -> Result<i32> {
    let records = api.list_intents()?;
    emit_success(json, &records, || list_human(&records));
    Ok(0)
}

/// `alloy intent show <slug>`.
pub fn show(api: &dyn Api, json: bool, slug: &str) -> Result<i32> {
    let record = api.get_intent(slug)?;
    emit_success(json, &record, || record_human(&record));
    Ok(0)
}

/// `alloy intent create --title ... [fields]`.
pub fn create(api: &dyn Api, json: bool, fields: IntentFields) -> Result<i32> {
    if fields.title.as_deref().unwrap_or("").trim().is_empty() {
        bail!("--title is required to create an intent record");
    }
    let record = api.create_intent(&fields.to_body())?;
    emit_success(json, &record, || {
        format!("Created {}\n\n{}", record.key, record_human(&record))
    });
    Ok(0)
}

/// `alloy intent update <slug> [fields]`.
pub fn update(api: &dyn Api, json: bool, slug: &str, fields: IntentFields) -> Result<i32> {
    if !fields.any_update_field() {
        bail!("nothing to update — pass at least one field, e.g. --title \"...\"");
    }
    let record = api.update_intent(slug, &fields.to_body())?;
    emit_success(json, &record, || {
        format!("Updated {}\n\n{}", record.key, record_human(&record))
    });
    Ok(0)
}

/// `alloy intent remove <slug>`.
pub fn remove(api: &dyn Api, json: bool, slug: &str) -> Result<i32> {
    api.delete_intent(slug)?;
    emit_success(json, &serde_json::json!({ "slug": slug }), || {
        format!("Removed intent record '{slug}'")
    });
    Ok(0)
}

/// `alloy intent <accept|activate|deprecate|contradict> <slug>`.
pub fn transition(api: &dyn Api, json: bool, slug: &str, transition: Transition) -> Result<i32> {
    let record = api.transition_intent(slug, transition, &serde_json::json!({}))?;
    emit_success(json, &record, || {
        format!("{} is now {}", record.key, record.status)
    });
    Ok(0)
}

/// `alloy intent supersede <slug> [--by <replacement-slug>]`.
pub fn supersede(api: &dyn Api, json: bool, slug: &str, by: Option<&str>) -> Result<i32> {
    let body = match by {
        Some(by) => serde_json::json!({ "by": by }),
        None => serde_json::json!({}),
    };
    let record = api.transition_intent(slug, Transition::Supersede, &body)?;
    emit_success(json, &record, || {
        let suffix = by.map(|b| format!(" by '{b}'")).unwrap_or_default();
        format!("{} superseded{suffix}", record.key)
    });
    Ok(0)
}

fn list_human(records: &[IntentRecord]) -> String {
    if records.is_empty() {
        return "No intent records yet.".to_string();
    }

    let mut out = String::new();
    let slug_width = records
        .iter()
        .map(|r| r.slug.len())
        .max()
        .unwrap_or(0)
        .max(4);
    let status_width = records
        .iter()
        .map(|r| r.status.len())
        .max()
        .unwrap_or(0)
        .max(6);

    out.push_str(&format!(
        "{:<slug_width$}  {:<status_width$}  TITLE\n",
        "SLUG", "STATUS"
    ));
    for r in records {
        out.push_str(&format!(
            "{:<slug_width$}  {:<status_width$}  {}\n",
            r.slug, r.status, r.title
        ));
    }
    out.trim_end().to_string()
}

fn record_human(r: &IntentRecord) -> String {
    let confidence = r
        .confidence
        .map(|c| format!("{c:.2}"))
        .unwrap_or_else(|| "—".to_string());

    format!(
        "{title}\n  \
         key:         {key}\n  \
         status:      {status}\n  \
         confidence:  {confidence}\n  \
         capability:  {capability}\n  \
         threat:      {threat}\n  \
         expectation: {expectation}\n  \
         strategy:    {strategy}\n  \
         evidence:    {evidence}\n  \
         tradeoff:    {tradeoff}",
        title = r.title,
        key = r.key,
        status = r.status,
        capability = or_dash(&r.capability),
        threat = or_dash(&r.threat),
        expectation = or_dash(&r.expectation),
        strategy = or_dash(&r.strategy),
        evidence = or_dash(&r.evidence_summary),
        tradeoff = or_dash(&r.tradeoff),
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::testsupport::FakeApi;

    #[test]
    fn to_body_includes_only_supplied_fields() {
        let fields = IntentFields {
            title: Some("Keep tests fast".into()),
            confidence: Some(0.8),
            ..Default::default()
        };
        let body = fields.to_body();
        let obj = body.as_object().unwrap();
        assert_eq!(obj.get("title").unwrap(), "Keep tests fast");
        assert_eq!(obj.get("confidence").unwrap().as_f64().unwrap(), 0.8);
        assert!(!obj.contains_key("threat"));
    }

    #[test]
    fn create_requires_title() {
        let api = FakeApi::new();
        let err = create(&api, false, IntentFields::default()).unwrap_err();
        assert!(err.to_string().contains("--title is required"));
    }

    #[test]
    fn create_then_show_roundtrips() {
        let api = FakeApi::new();
        let fields = IntentFields {
            title: Some("Keep tests fast".into()),
            slug: Some("keep-tests-fast".into()),
            ..Default::default()
        };
        assert_eq!(create(&api, true, fields).unwrap(), 0);
        assert_eq!(
            api.get_intent("keep-tests-fast").unwrap().title,
            "Keep tests fast"
        );
    }

    #[test]
    fn update_rejects_empty_change_set() {
        let api = FakeApi::new();
        let err = update(&api, false, "x", IntentFields::default()).unwrap_err();
        assert!(err.to_string().contains("nothing to update"));
    }

    #[test]
    fn update_with_only_slug_is_rejected() {
        let api = FakeApi::new();
        let fields = IntentFields {
            slug: Some("ignored".into()),
            ..Default::default()
        };
        let err = update(&api, false, "x", fields).unwrap_err();
        assert!(err.to_string().contains("nothing to update"));
    }

    #[test]
    fn transition_drives_status() {
        let api = FakeApi::new();
        api.seed_record("keep-tests-fast", "Keep tests fast", "proposed");
        assert_eq!(
            transition(&api, true, "keep-tests-fast", Transition::Accept).unwrap(),
            0
        );
        assert_eq!(
            api.get_intent("keep-tests-fast").unwrap().status,
            "accepted"
        );
    }

    #[test]
    fn supersede_links_replacement() {
        let api = FakeApi::new();
        api.seed_record("old", "Old", "active");
        assert_eq!(supersede(&api, true, "old", Some("new")).unwrap(), 0);
        let rec = api.get_intent("old").unwrap();
        assert_eq!(rec.status, "superseded");
    }
}
