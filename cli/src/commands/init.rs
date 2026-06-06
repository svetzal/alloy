//! `alloy init` — install (or update) the embedded agent skill files.
//!
//! The skill source lives in `cli/skills/alloy/` and is embedded into the binary
//! at compile time via [`include_str!`]. `init` writes those files into
//! `.claude/skills/alloy/` (or `~/.claude/skills/alloy/` with `--global`),
//! stamping each with the binary's version so a later `init` can tell what is
//! installed and refuse to overwrite a newer skill.
//!
//! This command takes **no** `.alloy_env` — it only writes files — so the binary
//! dispatches it before building the HTTP gateway.
//!
//! The version logic (stamp / strip / parse / semver / action planning) is a pure
//! core; the filesystem walk is the thin shell.

use std::cmp::Ordering;
use std::path::PathBuf;

use anyhow::{Context, Result};
use serde::Serialize;

use crate::output::emit_success;

/// The binary's version, stamped into installed skill files.
const VERSION: &str = env!("CARGO_PKG_VERSION");

/// An embedded skill file: its install path (relative to the `.claude` parent)
/// and its source content.
struct SkillFile {
    /// Path under the install root, e.g. `.claude/skills/alloy/SKILL.md`.
    rel_path: &'static str,
    content: &'static str,
}

/// The skill files embedded from `cli/skills/alloy/`, in install order.
const SKILL_FILES: &[SkillFile] = &[
    SkillFile {
        rel_path: ".claude/skills/alloy/SKILL.md",
        content: include_str!("../../skills/alloy/SKILL.md"),
    },
    SkillFile {
        rel_path: ".claude/skills/alloy/references/cli-reference.md",
        content: include_str!("../../skills/alloy/references/cli-reference.md"),
    },
    SkillFile {
        rel_path: ".claude/skills/alloy/references/intent-model.md",
        content: include_str!("../../skills/alloy/references/intent-model.md"),
    },
    SkillFile {
        rel_path: ".claude/skills/alloy/workflows/getting-started.md",
        content: include_str!("../../skills/alloy/workflows/getting-started.md"),
    },
    SkillFile {
        rel_path: ".claude/skills/alloy/workflows/capturing-intent.md",
        content: include_str!("../../skills/alloy/workflows/capturing-intent.md"),
    },
];

/// The frontmatter key that records which `alloy` version installed a file.
const VERSION_KEY: &str = "alloy_version:";

/// What `init` decided to do with one file.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Action {
    Created,
    Updated,
    UpToDate,
    Skipped,
}

impl Action {
    fn label(self) -> &'static str {
        match self {
            Action::Created => "created",
            Action::Updated => "updated",
            Action::UpToDate => "up-to-date",
            Action::Skipped => "skipped",
        }
    }

    fn icon(self) -> char {
        match self {
            Action::Created => '+',
            Action::Updated => '~',
            Action::UpToDate => '=',
            Action::Skipped => '!',
        }
    }
}

/// The pure decision for one file: what to do, the content to write (when any),
/// and an optional warning.
#[derive(Debug, Clone, PartialEq, Eq)]
struct Plan {
    action: Action,
    write: Option<String>,
    warning: Option<String>,
}

/// One file's outcome, serialized under `--json`.
#[derive(Debug, Serialize)]
struct FileResult {
    path: String,
    action: &'static str,
    #[serde(skip_serializing_if = "Option::is_none")]
    warning: Option<String>,
}

/// The data half of the response envelope for `init`.
#[derive(Debug, Serialize)]
struct InitData {
    version: &'static str,
    scope: &'static str,
    files: Vec<FileResult>,
    summary: String,
}

/// `alloy init [--global] [--force]`.
pub fn run(global: bool, force: bool, json: bool) -> Result<i32> {
    let base = base_dir(global)?;
    let scope = if global { "global" } else { "local" };

    let mut results: Vec<FileResult> = Vec::with_capacity(SKILL_FILES.len());

    for file in SKILL_FILES {
        let rel = install_rel_path(file.rel_path, global);
        let full = base.join(rel);

        let existing = std::fs::read_to_string(&full).ok();
        let plan = plan_action(existing.as_deref(), file.content, VERSION, force);

        if let Some(contents) = &plan.write {
            if let Some(parent) = full.parent() {
                std::fs::create_dir_all(parent)
                    .with_context(|| format!("could not create {}", parent.display()))?;
            }
            std::fs::write(&full, contents)
                .with_context(|| format!("could not write {}", full.display()))?;
        }

        results.push(FileResult {
            path: rel.to_string(),
            action: plan.action.label(),
            warning: plan.warning,
        });
    }

    let summary = summarize(&results);
    let data = InitData {
        version: VERSION,
        scope,
        files: results,
        summary: summary.clone(),
    };

    emit_success(json, &data, || human_report(scope, &data));
    Ok(0)
}

/// Where the `.claude` tree is rooted for this scope.
fn base_dir(global: bool) -> Result<PathBuf> {
    if global {
        let home = std::env::var_os("HOME").context("cannot install --global: HOME is not set")?;
        Ok(PathBuf::from(home).join(".claude"))
    } else {
        std::env::current_dir().context("could not determine current directory")
    }
}

/// The install path relative to [`base_dir`]. Local installs keep the `.claude/`
/// prefix under the project root; global installs drop it (the base is already
/// `~/.claude`).
fn install_rel_path(rel_path: &str, global: bool) -> &str {
    if global {
        rel_path.strip_prefix(".claude/").unwrap_or(rel_path)
    } else {
        rel_path
    }
}

/// Decides what to do with a file given its current on-disk contents (if any),
/// the embedded source, the binary version, and whether `--force` was passed.
fn plan_action(existing: Option<&str>, source: &str, version: &str, force: bool) -> Plan {
    let stamped = stamp_version(source, version);

    let Some(existing) = existing else {
        return Plan {
            action: Action::Created,
            write: Some(stamped),
            warning: None,
        };
    };

    let mut warning = None;
    if let Some(installed) = parse_installed_version(existing) {
        if compare_semver(&installed, version) == Ordering::Greater {
            if !force {
                return Plan {
                    action: Action::Skipped,
                    write: None,
                    warning: Some(format!(
                        "Installed skill is from alloy v{installed} but this binary is v{version}. \
                         Use --force to downgrade."
                    )),
                };
            }
            warning = Some(format!(
                "Downgrading skill from v{installed} to v{version} (--force)."
            ));
        }
    }

    if strip_version_stamp(existing) == source {
        // Body unchanged. Re-stamp only if the version line drifted.
        let write = (existing != stamped).then(|| stamped.clone());
        Plan {
            action: Action::UpToDate,
            write,
            warning,
        }
    } else {
        Plan {
            action: Action::Updated,
            write: Some(stamped),
            warning,
        }
    }
}

/// Splits `---\n…\n---\n<body>` into its frontmatter attributes and body. Returns
/// `None` when the content has no leading frontmatter block.
fn split_frontmatter(content: &str) -> Option<(&str, &str)> {
    let rest = content.strip_prefix("---\n")?;
    let close = rest.find("\n---\n")?;
    let attrs = &rest[..close];
    let body = &rest[close + "\n---\n".len()..];
    Some((attrs, body))
}

/// Injects (or replaces) the `alloy_version` line as the last frontmatter
/// attribute, adding a frontmatter block when the file has none.
fn stamp_version(content: &str, version: &str) -> String {
    let version_line = format!("{VERSION_KEY} {version}");
    match split_frontmatter(content) {
        Some((attrs, body)) => {
            let kept = attrs_without_version(attrs);
            if kept.is_empty() {
                format!("---\n{version_line}\n---\n{body}")
            } else {
                format!("---\n{kept}\n{version_line}\n---\n{body}")
            }
        }
        None => format!("---\n{version_line}\n---\n{content}"),
    }
}

/// Removes the `alloy_version` stamp, returning the file as it was authored. A
/// frontmatter block left empty by the removal is dropped entirely.
fn strip_version_stamp(content: &str) -> String {
    match split_frontmatter(content) {
        Some((attrs, body)) => {
            let kept = attrs_without_version(attrs);
            if kept.is_empty() {
                body.to_string()
            } else {
                format!("---\n{kept}\n---\n{body}")
            }
        }
        None => content.to_string(),
    }
}

/// The frontmatter attribute lines with any top-level `alloy_version` line
/// removed, rejoined.
fn attrs_without_version(attrs: &str) -> String {
    attrs
        .lines()
        .filter(|line| !line.starts_with(VERSION_KEY))
        .collect::<Vec<_>>()
        .join("\n")
}

/// Reads the `alloy_version` recorded in a file's frontmatter, if present.
fn parse_installed_version(content: &str) -> Option<String> {
    let (attrs, _) = split_frontmatter(content)?;
    attrs.lines().find_map(|line| {
        line.strip_prefix(VERSION_KEY)
            .map(|v| v.trim().to_string())
            .filter(|v| !v.is_empty())
    })
}

/// Compares two dotted numeric versions component-by-component (missing
/// components count as `0`).
fn compare_semver(a: &str, b: &str) -> Ordering {
    let parse = |s: &str| -> Vec<u64> { s.split('.').map(|p| p.parse().unwrap_or(0)).collect() };
    let (va, vb) = (parse(a), parse(b));
    for i in 0..va.len().max(vb.len()) {
        let (x, y) = (
            va.get(i).copied().unwrap_or(0),
            vb.get(i).copied().unwrap_or(0),
        );
        match x.cmp(&y) {
            Ordering::Equal => continue,
            other => return other,
        }
    }
    Ordering::Equal
}

/// A one-line "N created, M updated, …" summary of the per-file results.
fn summarize(results: &[FileResult]) -> String {
    let count = |label: &str| results.iter().filter(|r| r.action == label).count();
    let mut parts = Vec::new();
    for label in ["created", "updated", "up-to-date", "skipped"] {
        let n = count(label);
        if n > 0 {
            parts.push(format!("{n} {label}"));
        }
    }
    if parts.is_empty() {
        "no files".to_string()
    } else {
        parts.join(", ")
    }
}

/// The human (non-JSON) rendering.
fn human_report(scope: &str, data: &InitData) -> String {
    let mut out = format!("\nAlloy v{} — skill files ({scope})\n\n", data.version);
    for r in &data.files {
        let action = Action::from_label(r.action);
        out.push_str(&format!("  {} {}\n", action.icon(), r.path));
        if let Some(w) = &r.warning {
            out.push_str(&format!("    {w}\n"));
        }
    }
    out.push_str(&format!("\n{}", data.summary));
    out
}

impl Action {
    fn from_label(label: &str) -> Action {
        match label {
            "created" => Action::Created,
            "updated" => Action::Updated,
            "skipped" => Action::Skipped,
            _ => Action::UpToDate,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const FM_SOURCE: &str = "---\nname: alloy\ndescription: x\n---\nbody line\n";
    const PLAIN_SOURCE: &str = "# Heading\n\nbody\n";

    #[test]
    fn stamp_then_strip_round_trips_frontmatter_source() {
        let stamped = stamp_version(FM_SOURCE, "1.2.3");
        assert!(stamped.contains("alloy_version: 1.2.3"));
        assert_eq!(strip_version_stamp(&stamped), FM_SOURCE);
    }

    #[test]
    fn stamp_then_strip_round_trips_plain_source() {
        let stamped = stamp_version(PLAIN_SOURCE, "0.1.0");
        assert!(stamped.starts_with("---\nalloy_version: 0.1.0\n---\n"));
        assert_eq!(strip_version_stamp(&stamped), PLAIN_SOURCE);
    }

    #[test]
    fn stamp_replaces_an_existing_version_line() {
        let once = stamp_version(FM_SOURCE, "1.0.0");
        let twice = stamp_version(&once, "2.0.0");
        assert!(twice.contains("alloy_version: 2.0.0"));
        assert!(!twice.contains("alloy_version: 1.0.0"));
        // Exactly one stamp remains.
        assert_eq!(twice.matches("alloy_version:").count(), 1);
    }

    #[test]
    fn parses_installed_version() {
        let stamped = stamp_version(PLAIN_SOURCE, "3.4.5");
        assert_eq!(parse_installed_version(&stamped).as_deref(), Some("3.4.5"));
        assert_eq!(parse_installed_version(PLAIN_SOURCE), None);
    }

    #[test]
    fn semver_ordering() {
        assert_eq!(compare_semver("1.0.0", "1.0.0"), Ordering::Equal);
        assert_eq!(compare_semver("1.2.0", "1.10.0"), Ordering::Less);
        assert_eq!(compare_semver("2.0.0", "1.9.9"), Ordering::Greater);
        assert_eq!(compare_semver("1.0", "1.0.0"), Ordering::Equal);
    }

    #[test]
    fn plan_creates_when_absent() {
        let plan = plan_action(None, PLAIN_SOURCE, "0.1.0", false);
        assert_eq!(plan.action, Action::Created);
        assert!(plan.write.is_some());
        assert!(plan.warning.is_none());
    }

    #[test]
    fn plan_is_up_to_date_for_identical_stamped_file() {
        let installed = stamp_version(PLAIN_SOURCE, "0.1.0");
        let plan = plan_action(Some(&installed), PLAIN_SOURCE, "0.1.0", false);
        assert_eq!(plan.action, Action::UpToDate);
        assert!(plan.write.is_none(), "no rewrite when already current");
    }

    #[test]
    fn plan_restamps_when_only_version_drifted() {
        let installed = stamp_version(PLAIN_SOURCE, "0.0.9");
        let plan = plan_action(Some(&installed), PLAIN_SOURCE, "0.1.0", false);
        assert_eq!(plan.action, Action::UpToDate);
        assert_eq!(plan.write, Some(stamp_version(PLAIN_SOURCE, "0.1.0")));
    }

    #[test]
    fn plan_updates_when_body_changed() {
        let installed = stamp_version("# Old\n", "0.1.0");
        let plan = plan_action(Some(&installed), PLAIN_SOURCE, "0.1.0", false);
        assert_eq!(plan.action, Action::Updated);
        assert_eq!(plan.write, Some(stamp_version(PLAIN_SOURCE, "0.1.0")));
    }

    #[test]
    fn plan_skips_a_downgrade_without_force() {
        let installed = stamp_version("# New\n", "9.9.9");
        let plan = plan_action(Some(&installed), PLAIN_SOURCE, "0.1.0", false);
        assert_eq!(plan.action, Action::Skipped);
        assert!(plan.write.is_none());
        assert!(plan.warning.unwrap().contains("--force"));
    }

    #[test]
    fn plan_downgrades_with_force() {
        let installed = stamp_version("# New\n", "9.9.9");
        let plan = plan_action(Some(&installed), PLAIN_SOURCE, "0.1.0", true);
        assert_eq!(plan.action, Action::Updated);
        assert!(plan.write.is_some());
        assert!(plan.warning.unwrap().contains("Downgrading"));
    }

    #[test]
    fn embedded_skill_files_are_present_and_stampable() {
        // include_str! would fail the build if a path were wrong; assert the
        // content is non-trivial and round-trips through the stamp.
        for file in SKILL_FILES {
            assert!(file.content.len() > 100, "{} looks empty", file.rel_path);
            let stamped = stamp_version(file.content, VERSION);
            assert_eq!(strip_version_stamp(&stamped), file.content);
            assert_eq!(parse_installed_version(&stamped).as_deref(), Some(VERSION));
        }
    }

    #[test]
    fn global_install_drops_the_dotclaude_prefix() {
        assert_eq!(
            install_rel_path(".claude/skills/alloy/SKILL.md", true),
            "skills/alloy/SKILL.md"
        );
        assert_eq!(
            install_rel_path(".claude/skills/alloy/SKILL.md", false),
            ".claude/skills/alloy/SKILL.md"
        );
    }
}
