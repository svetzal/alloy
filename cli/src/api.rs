//! The backend gateway: the `Api` trait the commands depend on, plus the serde
//! types mirroring the JSON API's resource shapes and `{success, data, error}`
//! envelope.
//!
//! Commands and `validate` are written against this trait (the imperative
//! shell's boundary), so their logic is testable with an in-memory fake; the
//! real HTTP implementation lives in [`crate::http`].

use anyhow::{anyhow, Result};
use serde::{Deserialize, Serialize};

/// A project as returned by `/api/v1/project`.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Project {
    pub key: String,
    pub name: String,
    #[serde(default)]
    pub inserted_at: Option<String>,
    #[serde(default)]
    pub updated_at: Option<String>,
}

/// A project's charter as returned by `/api/v1/charter`. Every field is
/// optional — an unset charter serializes to all-`null`.
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq, Eq)]
pub struct Charter {
    #[serde(default)]
    pub mission: Option<String>,
    #[serde(default)]
    pub target_audience: Option<String>,
    #[serde(default)]
    pub problem_space: Option<String>,
    #[serde(default)]
    pub differentiators: Option<String>,
    #[serde(default)]
    pub out_of_scope: Option<String>,
}

impl Charter {
    /// The five canonical field names paired with their values, in order.
    pub fn fields(&self) -> [(&'static str, &Option<String>); 5] {
        [
            ("mission", &self.mission),
            ("target_audience", &self.target_audience),
            ("problem_space", &self.problem_space),
            ("differentiators", &self.differentiators),
            ("out_of_scope", &self.out_of_scope),
        ]
    }

    /// True once any field is filled in.
    pub fn present(&self) -> bool {
        self.fields()
            .iter()
            .any(|(_, v)| matches!(v, Some(s) if !s.trim().is_empty()))
    }
}

/// An engineering intent record as returned by `/api/v1/intents`.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct IntentRecord {
    pub key: String,
    pub project_key: String,
    pub slug: String,
    pub title: String,
    #[serde(default)]
    pub capability: Option<String>,
    #[serde(default)]
    pub threat: Option<String>,
    #[serde(default)]
    pub expectation: Option<String>,
    #[serde(default)]
    pub strategy: Option<String>,
    #[serde(default)]
    pub evidence_summary: Option<String>,
    #[serde(default)]
    pub tradeoff: Option<String>,
    pub status: String,
    #[serde(default)]
    pub confidence: Option<f64>,
    #[serde(default)]
    pub version: Option<i64>,
    #[serde(default)]
    pub scope: Option<serde_json::Value>,
    #[serde(default)]
    pub supersedes_id: Option<String>,
    #[serde(default)]
    pub inserted_at: Option<String>,
    #[serde(default)]
    pub updated_at: Option<String>,
}

/// The shared response envelope every `/api/v1` endpoint returns.
#[derive(Debug, Clone, Deserialize)]
pub struct Envelope<T> {
    pub success: bool,
    #[serde(default = "none")]
    pub data: Option<T>,
    #[serde(default)]
    pub error: Option<ApiError>,
}

fn none<T>() -> Option<T> {
    None
}

/// The error half of the envelope.
#[derive(Debug, Clone, Deserialize)]
pub struct ApiError {
    pub message: String,
    #[serde(default)]
    pub code: Option<String>,
    #[serde(default)]
    pub details: Option<serde_json::Value>,
}

impl<T> Envelope<T> {
    /// Unwraps a successful envelope's `data`, turning a failure envelope or a
    /// success-without-data into a descriptive error.
    pub fn into_data(self) -> Result<T> {
        if self.success {
            self.data
                .ok_or_else(|| anyhow!("API returned success with no data"))
        } else {
            Err(self.into_error())
        }
    }

    /// Turns the envelope into an error carrying the server's message (and code,
    /// when present).
    pub fn into_error(self) -> anyhow::Error {
        match self.error {
            Some(ApiError {
                message,
                code: Some(code),
                ..
            }) => anyhow!("{message} ({code})"),
            Some(ApiError { message, .. }) => anyhow!("{message}"),
            None => anyhow!("API request failed"),
        }
    }
}

/// A lifecycle transition a record can be driven through.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Transition {
    Accept,
    Activate,
    Deprecate,
    Contradict,
    Supersede,
}

impl Transition {
    /// The API sub-path segment for this transition.
    pub fn path(self) -> &'static str {
        match self {
            Transition::Accept => "accept",
            Transition::Activate => "activate",
            Transition::Deprecate => "deprecate",
            Transition::Contradict => "contradict",
            Transition::Supersede => "supersede",
        }
    }
}

/// The backend gateway. Implemented by [`crate::http::HttpApi`] in production
/// and by in-memory fakes in tests.
pub trait Api {
    /// Fetches the token-scoped project.
    fn get_project(&self) -> Result<Project>;

    /// Updates the project's mutable fields (currently just `name`).
    fn update_project(&self, name: &str) -> Result<Project>;

    /// Fetches the project's charter (all-`null` when unset).
    fn get_charter(&self) -> Result<Charter>;

    /// Upserts the project's charter from a partial JSON body. Only the keys
    /// present are written, so a single `--field` does not clear the others; a
    /// key with an empty-string value clears that field (the backend normalizes
    /// blank to null).
    fn update_charter(&self, body: &serde_json::Value) -> Result<Charter>;

    /// Lists the project's intent records.
    fn list_intents(&self) -> Result<Vec<IntentRecord>>;

    /// Fetches one intent record by its project-local slug.
    fn get_intent(&self, slug: &str) -> Result<IntentRecord>;

    /// Creates an intent record from a JSON body.
    fn create_intent(&self, body: &serde_json::Value) -> Result<IntentRecord>;

    /// Updates an intent record from a JSON body.
    fn update_intent(&self, slug: &str, body: &serde_json::Value) -> Result<IntentRecord>;

    /// Removes an intent record.
    fn delete_intent(&self, slug: &str) -> Result<()>;

    /// Drives an intent record through a lifecycle `transition`. The `body` is
    /// transition-specific (e.g. `{"by": "<slug>"}` for supersede); pass an
    /// empty object otherwise.
    fn transition_intent(
        &self,
        slug: &str,
        transition: Transition,
        body: &serde_json::Value,
    ) -> Result<IntentRecord>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn charter_present_is_false_when_all_blank() {
        let charter = Charter {
            mission: Some("   ".into()),
            ..Default::default()
        };
        assert!(!charter.present());
        assert!(!Charter::default().present());
    }

    #[test]
    fn charter_present_is_true_with_any_field() {
        let charter = Charter {
            problem_space: Some("drift".into()),
            ..Default::default()
        };
        assert!(charter.present());
    }

    #[test]
    fn envelope_into_data_returns_data_on_success() {
        let env: Envelope<Project> = serde_json::from_str(
            r#"{"success":true,"data":{"key":"acme","name":"Acme"},"error":null}"#,
        )
        .unwrap();
        assert_eq!(env.into_data().unwrap().key, "acme");
    }

    #[test]
    fn envelope_into_data_surfaces_error_message_and_code() {
        let env: Envelope<Project> = serde_json::from_str(
            r#"{"success":false,"data":null,"error":{"message":"Not found.","code":"not_found"}}"#,
        )
        .unwrap();
        let err = env.into_data().unwrap_err().to_string();
        assert!(err.contains("Not found."));
        assert!(err.contains("not_found"));
    }

    #[test]
    fn transition_paths() {
        assert_eq!(Transition::Accept.path(), "accept");
        assert_eq!(Transition::Supersede.path(), "supersede");
    }
}
