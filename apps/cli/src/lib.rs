//! `alloy` — a thin-client CLI for the Alloy engineering-intent backend.
//!
//! The crate is split into a functional core (command logic over the
//! [`api::Api`] gateway trait, plus pure helpers) and an imperative shell (the
//! [`http`] gateway and the `main` binary). This makes command behaviour
//! testable without a live backend.

pub mod api;
pub mod commands;
pub mod config;
pub mod http;
pub mod output;

#[cfg(test)]
pub mod testsupport;
