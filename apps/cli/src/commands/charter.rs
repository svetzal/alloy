//! `alloy charter` — show or set the project's product charter.

use anyhow::{bail, Result};
use serde_json::{Map, Value};

use crate::api::{Api, Charter};
use crate::output::emit_success;

/// The five charter fields as supplied on the command line. A `None` field is
/// left untouched; a `Some("")` clears the field (the backend normalizes blank
/// to null).
#[derive(Debug, Default, Clone)]
pub struct CharterFields {
    pub mission: Option<String>,
    pub target_audience: Option<String>,
    pub problem_space: Option<String>,
    pub differentiators: Option<String>,
    pub out_of_scope: Option<String>,
}

impl CharterFields {
    /// Builds a partial JSON body of only the fields that were supplied, so a
    /// single `--field` does not clear the others.
    fn to_body(&self) -> Value {
        let mut map = Map::new();
        let pairs = [
            ("mission", &self.mission),
            ("target_audience", &self.target_audience),
            ("problem_space", &self.problem_space),
            ("differentiators", &self.differentiators),
            ("out_of_scope", &self.out_of_scope),
        ];
        for (key, value) in pairs {
            if let Some(v) = value {
                map.insert(key.to_string(), Value::String(v.clone()));
            }
        }
        Value::Object(map)
    }

    fn any_set(&self) -> bool {
        self.to_body().as_object().is_some_and(|m| !m.is_empty())
    }
}

/// `alloy charter show`.
pub fn show(api: &dyn Api, json: bool) -> Result<i32> {
    let charter = api.get_charter()?;
    emit_success(json, &charter, || human(&charter));
    Ok(0)
}

/// `alloy charter set [--field ...]`.
pub fn set(api: &dyn Api, json: bool, fields: CharterFields) -> Result<i32> {
    if !fields.any_set() {
        bail!("nothing to set — pass at least one field, e.g. --mission \"...\"");
    }

    let charter = api.update_charter(&fields.to_body())?;
    emit_success(json, &charter, || {
        format!("Charter saved.\n\n{}", human(&charter))
    });
    Ok(0)
}

fn human(charter: &Charter) -> String {
    if !charter.present() {
        return "No charter set. Use `alloy charter set --mission \"...\"` to start.".to_string();
    }

    charter
        .fields()
        .iter()
        .filter_map(|(label, value)| {
            value
                .as_ref()
                .filter(|s| !s.trim().is_empty())
                .map(|s| format!("{}: {}", pretty_label(label), s))
        })
        .collect::<Vec<_>>()
        .join("\n")
}

fn pretty_label(field: &str) -> &str {
    match field {
        "mission" => "Mission",
        "target_audience" => "Target audience",
        "problem_space" => "Problem space",
        "differentiators" => "Differentiators",
        "out_of_scope" => "Out of scope",
        other => other,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::testsupport::FakeApi;

    #[test]
    fn set_rejects_when_no_fields_given() {
        let api = FakeApi::new();
        let err = set(&api, false, CharterFields::default()).unwrap_err();
        assert!(err.to_string().contains("at least one field"));
    }

    #[test]
    fn set_persists_supplied_fields() {
        let api = FakeApi::new();
        let fields = CharterFields {
            mission: Some("Preserve intent".into()),
            ..Default::default()
        };
        assert_eq!(set(&api, true, fields).unwrap(), 0);
        assert_eq!(
            api.get_charter().unwrap().mission.as_deref(),
            Some("Preserve intent")
        );
    }
}
