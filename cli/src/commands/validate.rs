//! `alloy validate` — referential-integrity and shape checks over the project's
//! charter and intent records.
//!
//! The checks feasible from the token-scoped API today: slug well-formedness and
//! uniqueness, known lifecycle statuses, and charter presence. Deeper
//! cross-record checks (resolving `supersedes_id` to a record) need the API to
//! expose the link as a slug and are deferred to a later phase.

use std::collections::HashMap;

use anyhow::Result;
use serde::Serialize;

use crate::api::{Api, Charter, IntentRecord};
use crate::output::emit_success;

/// The valid lifecycle statuses, mirroring `Alloy.Intent.Record`.
const STATUSES: [&str; 7] = [
    "hypothesized",
    "proposed",
    "accepted",
    "active",
    "deprecated",
    "contradicted",
    "superseded",
];

/// The severity of a validation issue. Only errors make a run invalid.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum Severity {
    Error,
    Warning,
}

/// A single validation finding.
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct Issue {
    pub severity: Severity,
    /// The entity the issue concerns (e.g. an intent slug, or "charter").
    pub entity: String,
    pub message: String,
}

/// The outcome of a validation run.
#[derive(Debug, Clone, Serialize)]
pub struct Report {
    pub valid: bool,
    pub issues: Vec<Issue>,
    pub summary: Summary,
}

/// Counts for the validation run.
#[derive(Debug, Clone, Serialize)]
pub struct Summary {
    pub intents: usize,
    pub errors: usize,
    pub warnings: usize,
}

/// Runs the pure validation logic over already-fetched data.
pub fn check(charter: &Charter, records: &[IntentRecord]) -> Report {
    let mut issues = Vec::new();

    if !charter.present() {
        issues.push(Issue {
            severity: Severity::Warning,
            entity: "charter".to_string(),
            message: "no charter set — downstream intent has no product context to ground it"
                .to_string(),
        });
    }

    let mut seen: HashMap<&str, usize> = HashMap::new();
    for record in records {
        *seen.entry(record.slug.as_str()).or_insert(0) += 1;

        if !is_valid_slug(&record.slug) {
            issues.push(Issue {
                severity: Severity::Error,
                entity: record.slug.clone(),
                message: format!(
                    "slug '{}' is not a valid key (expected lowercase letters, numbers, \
                     underscores, or hyphens)",
                    record.slug
                ),
            });
        }

        if !STATUSES.contains(&record.status.as_str()) {
            issues.push(Issue {
                severity: Severity::Error,
                entity: record.slug.clone(),
                message: format!("unknown status '{}'", record.status),
            });
        }
    }

    for (slug, count) in seen.iter() {
        if *count > 1 {
            issues.push(Issue {
                severity: Severity::Error,
                entity: (*slug).to_string(),
                message: format!("slug '{slug}' appears {count} times — slugs must be unique"),
            });
        }
    }

    let errors = issues
        .iter()
        .filter(|i| i.severity == Severity::Error)
        .count();
    let warnings = issues.len() - errors;

    Report {
        valid: errors == 0,
        issues,
        summary: Summary {
            intents: records.len(),
            errors,
            warnings,
        },
    }
}

/// `alloy validate`. Exit code is `0` when valid, `1` when any error is found.
pub fn run(api: &dyn Api, json: bool) -> Result<i32> {
    let charter = api.get_charter()?;
    let records = api.list_intents()?;
    let report = check(&charter, &records);
    let code = if report.valid { 0 } else { 1 };

    emit_success(json, &report, || human(&report));
    Ok(code)
}

/// True when `slug` matches `^[a-z0-9_-]+$`.
fn is_valid_slug(slug: &str) -> bool {
    !slug.is_empty()
        && slug
            .chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '_' || c == '-')
}

fn human(report: &Report) -> String {
    let mut out = String::new();

    for issue in &report.issues {
        let tag = match issue.severity {
            Severity::Error => "error",
            Severity::Warning => "warn",
        };
        out.push_str(&format!("[{tag}] {}: {}\n", issue.entity, issue.message));
    }

    let headline = if report.valid {
        "OK".to_string()
    } else {
        "FAILED".to_string()
    };
    out.push_str(&format!(
        "{headline} — {} intent record(s), {} error(s), {} warning(s)",
        report.summary.intents, report.summary.errors, report.summary.warnings
    ));

    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn record(slug: &str, status: &str) -> IntentRecord {
        IntentRecord {
            key: format!("acme.intent.{slug}"),
            project_key: "acme".into(),
            slug: slug.into(),
            title: "T".into(),
            capability: None,
            threat: None,
            expectation: None,
            strategy: None,
            evidence_summary: None,
            tradeoff: None,
            status: status.into(),
            confidence: None,
            version: None,
            scope: None,
            supersedes_id: None,
            inserted_at: None,
            updated_at: None,
        }
    }

    #[test]
    fn clean_project_is_valid_but_warns_on_missing_charter() {
        let report = check(&Charter::default(), &[record("a", "proposed")]);
        assert!(report.valid);
        assert_eq!(report.summary.warnings, 1);
        assert_eq!(report.summary.errors, 0);
    }

    #[test]
    fn flags_invalid_slug() {
        let charter = Charter {
            mission: Some("m".into()),
            ..Default::default()
        };
        let report = check(&charter, &[record("Not A Slug", "proposed")]);
        assert!(!report.valid);
        assert!(report
            .issues
            .iter()
            .any(|i| i.message.contains("not a valid key")));
    }

    #[test]
    fn flags_unknown_status() {
        let charter = Charter {
            mission: Some("m".into()),
            ..Default::default()
        };
        let report = check(&charter, &[record("ok", "bogus")]);
        assert!(!report.valid);
        assert!(report
            .issues
            .iter()
            .any(|i| i.message.contains("unknown status")));
    }

    #[test]
    fn flags_duplicate_slugs() {
        let charter = Charter {
            mission: Some("m".into()),
            ..Default::default()
        };
        let report = check(
            &charter,
            &[record("dup", "proposed"), record("dup", "active")],
        );
        assert!(!report.valid);
        assert!(report
            .issues
            .iter()
            .any(|i| i.message.contains("must be unique")));
    }
}
