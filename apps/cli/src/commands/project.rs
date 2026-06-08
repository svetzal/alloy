//! `alloy project` — inspect or rename the token-scoped project.

use anyhow::Result;

use crate::api::{Api, Project};
use crate::output::emit_success;

/// `alloy project show`.
pub fn show(api: &dyn Api, json: bool) -> Result<i32> {
    let project = api.get_project()?;
    emit_success(json, &project, || human(&project));
    Ok(0)
}

/// `alloy project set --name <name>`.
pub fn set(api: &dyn Api, json: bool, name: &str) -> Result<i32> {
    let project = api.update_project(name)?;
    emit_success(json, &project, || {
        format!("Project renamed to {}", project.name)
    });
    Ok(0)
}

fn human(project: &Project) -> String {
    format!("{}\n  key:  {}", project.name, project.key)
}
