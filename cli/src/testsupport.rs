//! In-memory [`Api`] fake for exercising command logic without a backend.
//!
//! Only compiled under `cfg(test)`. It models just enough of the backend's
//! behaviour (partial charter upsert, the intent lifecycle state machine) for
//! the command tests to be meaningful.

use std::cell::RefCell;
use std::collections::BTreeMap;

use anyhow::{anyhow, Result};
use serde_json::Value;

use crate::api::{Api, Charter, IntentRecord, Project, Transition};

/// A configurable in-memory backend.
pub struct FakeApi {
    project: RefCell<Project>,
    charter: RefCell<Charter>,
    records: RefCell<BTreeMap<String, IntentRecord>>,
}

impl FakeApi {
    /// A fake seeded with an empty "acme"/"Acme" project and no charter.
    pub fn new() -> FakeApi {
        FakeApi {
            project: RefCell::new(Project {
                key: "acme".into(),
                name: "Acme".into(),
                inserted_at: None,
                updated_at: None,
            }),
            charter: RefCell::new(Charter::default()),
            records: RefCell::new(BTreeMap::new()),
        }
    }

    /// Inserts a record directly, bypassing the create path.
    pub fn seed_record(&self, slug: &str, title: &str, status: &str) {
        self.records.borrow_mut().insert(
            slug.to_string(),
            IntentRecord {
                key: format!("acme.intent.{slug}"),
                project_key: "acme".into(),
                slug: slug.into(),
                title: title.into(),
                capability: None,
                threat: None,
                expectation: None,
                strategy: None,
                evidence_summary: None,
                tradeoff: None,
                status: status.into(),
                confidence: Some(1.0),
                version: Some(1),
                scope: None,
                supersedes_id: None,
                supersedes_slug: None,
                inserted_at: None,
                updated_at: None,
            },
        );
    }

    fn slug_from(body: &Value, fallback_title: &str) -> String {
        body.get("slug")
            .and_then(Value::as_str)
            .filter(|s| !s.is_empty())
            .map(slugify)
            .unwrap_or_else(|| slugify(fallback_title))
    }
}

impl Default for FakeApi {
    fn default() -> Self {
        FakeApi::new()
    }
}

fn slugify(input: &str) -> String {
    input
        .to_lowercase()
        .chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '-' })
        .collect::<String>()
        .trim_matches('-')
        .to_string()
}

// Mirrors Alloy.Intent.Record's allowed transitions.
fn target_status(from: &str, transition: Transition) -> Result<&'static str> {
    let ok = |allowed: &[&str], target: &'static str| {
        if allowed.contains(&from) {
            Ok(target)
        } else {
            Err(anyhow!("cannot transition a record that is {from}"))
        }
    };

    match transition {
        Transition::Accept => ok(&["hypothesized", "proposed"], "accepted"),
        Transition::Activate => ok(&["accepted"], "active"),
        Transition::Deprecate => ok(&["accepted", "active"], "deprecated"),
        Transition::Contradict => ok(
            &[
                "hypothesized",
                "proposed",
                "accepted",
                "active",
                "deprecated",
            ],
            "contradicted",
        ),
        Transition::Supersede => ok(
            &[
                "hypothesized",
                "proposed",
                "accepted",
                "active",
                "deprecated",
            ],
            "superseded",
        ),
    }
}

impl Api for FakeApi {
    fn get_project(&self) -> Result<Project> {
        Ok(self.project.borrow().clone())
    }

    fn update_project(&self, name: &str) -> Result<Project> {
        self.project.borrow_mut().name = name.to_string();
        Ok(self.project.borrow().clone())
    }

    fn get_charter(&self) -> Result<Charter> {
        Ok(self.charter.borrow().clone())
    }

    fn update_charter(&self, body: &Value) -> Result<Charter> {
        let mut charter = self.charter.borrow_mut();
        let apply = |key: &str, slot: &mut Option<String>| {
            if let Some(v) = body.get(key).and_then(Value::as_str) {
                let trimmed = v.trim();
                *slot = if trimmed.is_empty() {
                    None
                } else {
                    Some(trimmed.to_string())
                };
            }
        };
        apply("mission", &mut charter.mission);
        apply("target_audience", &mut charter.target_audience);
        apply("problem_space", &mut charter.problem_space);
        apply("differentiators", &mut charter.differentiators);
        apply("out_of_scope", &mut charter.out_of_scope);
        Ok(charter.clone())
    }

    fn list_intents(&self) -> Result<Vec<IntentRecord>> {
        Ok(self.records.borrow().values().cloned().collect())
    }

    fn get_intent(&self, slug: &str) -> Result<IntentRecord> {
        self.records
            .borrow()
            .get(slug)
            .cloned()
            .ok_or_else(|| anyhow!("Not found."))
    }

    fn create_intent(&self, body: &Value) -> Result<IntentRecord> {
        let title = body
            .get("title")
            .and_then(Value::as_str)
            .ok_or_else(|| anyhow!("title is required"))?
            .to_string();
        let slug = FakeApi::slug_from(body, &title);

        let record = IntentRecord {
            key: format!("acme.intent.{slug}"),
            project_key: "acme".into(),
            slug: slug.clone(),
            title,
            capability: body
                .get("capability")
                .and_then(Value::as_str)
                .map(Into::into),
            threat: body.get("threat").and_then(Value::as_str).map(Into::into),
            expectation: body
                .get("expectation")
                .and_then(Value::as_str)
                .map(Into::into),
            strategy: body.get("strategy").and_then(Value::as_str).map(Into::into),
            evidence_summary: body
                .get("evidence_summary")
                .and_then(Value::as_str)
                .map(Into::into),
            tradeoff: body.get("tradeoff").and_then(Value::as_str).map(Into::into),
            status: body
                .get("status")
                .and_then(Value::as_str)
                .unwrap_or("proposed")
                .to_string(),
            confidence: body.get("confidence").and_then(Value::as_f64).or(Some(1.0)),
            version: Some(1),
            scope: None,
            supersedes_id: None,
            supersedes_slug: None,
            inserted_at: None,
            updated_at: None,
        };

        self.records.borrow_mut().insert(slug, record.clone());
        Ok(record)
    }

    fn update_intent(&self, slug: &str, body: &Value) -> Result<IntentRecord> {
        let mut records = self.records.borrow_mut();
        let record = records.get_mut(slug).ok_or_else(|| anyhow!("Not found."))?;

        let apply = |slot: &mut Option<String>, key: &str| {
            if let Some(v) = body.get(key).and_then(Value::as_str) {
                *slot = Some(v.to_string());
            }
        };
        if let Some(v) = body.get("title").and_then(Value::as_str) {
            record.title = v.to_string();
        }
        apply(&mut record.capability, "capability");
        apply(&mut record.threat, "threat");
        apply(&mut record.expectation, "expectation");
        apply(&mut record.strategy, "strategy");
        apply(&mut record.evidence_summary, "evidence_summary");
        apply(&mut record.tradeoff, "tradeoff");
        if let Some(v) = body.get("status").and_then(Value::as_str) {
            record.status = v.to_string();
        }
        if let Some(c) = body.get("confidence").and_then(Value::as_f64) {
            record.confidence = Some(c);
        }
        Ok(record.clone())
    }

    fn delete_intent(&self, slug: &str) -> Result<()> {
        self.records
            .borrow_mut()
            .remove(slug)
            .map(|_| ())
            .ok_or_else(|| anyhow!("Not found."))
    }

    fn transition_intent(
        &self,
        slug: &str,
        transition: Transition,
        _body: &Value,
    ) -> Result<IntentRecord> {
        let mut records = self.records.borrow_mut();
        let record = records.get_mut(slug).ok_or_else(|| anyhow!("Not found."))?;
        record.status = target_status(&record.status, transition)?.to_string();
        Ok(record.clone())
    }
}
