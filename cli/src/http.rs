//! The real [`Api`] gateway: a thin `reqwest` blocking client over the
//! `/api/v1` JSON API.
//!
//! This module is deliberately logic-free — it builds requests, attaches the
//! bearer token, and decodes the `{success, data, error}` envelope. All
//! decision-making lives in the command layer against the [`Api`] trait.

use anyhow::{Context, Result};
use reqwest::blocking::Client;
use reqwest::Method;
use serde::de::DeserializeOwned;
use serde_json::json;

use crate::api::{Api, Charter, Envelope, IntentRecord, Project, Transition};
use crate::config::Config;

/// HTTP implementation of [`Api`] backed by `reqwest`.
pub struct HttpApi {
    client: Client,
    base: String,
    token: String,
}

impl HttpApi {
    /// Builds a client from a resolved [`Config`].
    pub fn new(config: Config) -> Result<HttpApi> {
        let client = Client::builder()
            .user_agent(concat!("alloy-cli/", env!("CARGO_PKG_VERSION")))
            .build()
            .context("could not build HTTP client")?;

        Ok(HttpApi {
            client,
            base: format!("{}/api/v1", config.host),
            token: config.token,
        })
    }

    fn url(&self, path: &str) -> String {
        format!("{}{}", self.base, path)
    }

    /// Sends a request with an optional JSON body and decodes the
    /// `{success, data, error}` envelope, deserializing `data` as `T`.
    fn request_envelope<T: DeserializeOwned>(
        &self,
        method: Method,
        path: &str,
        body: Option<&serde_json::Value>,
    ) -> Result<Envelope<T>> {
        let mut req = self
            .client
            .request(method, self.url(path))
            .bearer_auth(&self.token);

        if let Some(body) = body {
            req = req.json(body);
        }

        let resp = req
            .send()
            .with_context(|| format!("request to {} failed", self.url(path)))?;

        let status = resp.status();
        let text = resp.text().context("could not read response body")?;

        serde_json::from_str(&text).with_context(|| {
            format!(
                "unexpected response (HTTP {status}) from {}",
                self.url(path)
            )
        })
    }

    /// Sends a request and unwraps the envelope's `data` as `T`.
    fn send<T: DeserializeOwned>(
        &self,
        method: Method,
        path: &str,
        body: Option<&serde_json::Value>,
    ) -> Result<T> {
        self.request_envelope(method, path, body)?.into_data()
    }

    /// Sends a request that returns no payload, checking only `success` (so a
    /// `{success: true, data: null}` response is accepted, e.g. on delete).
    fn send_unit(
        &self,
        method: Method,
        path: &str,
        body: Option<&serde_json::Value>,
    ) -> Result<()> {
        let envelope: Envelope<serde_json::Value> = self.request_envelope(method, path, body)?;
        if envelope.success {
            Ok(())
        } else {
            Err(envelope.into_error())
        }
    }
}

impl Api for HttpApi {
    fn get_project(&self) -> Result<Project> {
        self.send(Method::GET, "/project", None)
    }

    fn update_project(&self, name: &str) -> Result<Project> {
        self.send(Method::PATCH, "/project", Some(&json!({ "name": name })))
    }

    fn get_charter(&self) -> Result<Charter> {
        self.send(Method::GET, "/charter", None)
    }

    fn update_charter(&self, body: &serde_json::Value) -> Result<Charter> {
        self.send(Method::PATCH, "/charter", Some(body))
    }

    fn list_intents(&self) -> Result<Vec<IntentRecord>> {
        self.send(Method::GET, "/intents", None)
    }

    fn get_intent(&self, slug: &str) -> Result<IntentRecord> {
        self.send(Method::GET, &format!("/intents/{slug}"), None)
    }

    fn create_intent(&self, body: &serde_json::Value) -> Result<IntentRecord> {
        self.send(Method::POST, "/intents", Some(body))
    }

    fn update_intent(&self, slug: &str, body: &serde_json::Value) -> Result<IntentRecord> {
        self.send(Method::PATCH, &format!("/intents/{slug}"), Some(body))
    }

    fn delete_intent(&self, slug: &str) -> Result<()> {
        self.send_unit(Method::DELETE, &format!("/intents/{slug}"), None)
    }

    fn transition_intent(
        &self,
        slug: &str,
        transition: Transition,
        body: &serde_json::Value,
    ) -> Result<IntentRecord> {
        self.send(
            Method::POST,
            &format!("/intents/{slug}/{}", transition.path()),
            Some(body),
        )
    }
}
