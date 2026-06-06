//! Command implementations. Each is written against the [`crate::api::Api`]
//! trait so it can be unit-tested with an in-memory fake.

pub mod charter;
pub mod docs;
pub mod intent;
pub mod project;
pub mod validate;
