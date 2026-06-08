//! Command implementations. The backend-facing commands are written against the
//! [`crate::api::Api`] trait so they can be unit-tested with an in-memory fake;
//! [`init`] is the exception — it only writes embedded skill files and so takes
//! no gateway.

pub mod charter;
pub mod docs;
pub mod init;
pub mod intent;
pub mod project;
pub mod validate;
