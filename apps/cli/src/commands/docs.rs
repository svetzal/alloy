//! `alloy docs --agents` — generate agent-facing guidance for working with the
//! `alloy` CLI in a project, with the project's live charter and its binding
//! (accepted/active) intent records woven in.

use std::path::Path;

use anyhow::{Context, Result};

use crate::api::{Api, Charter, IntentRecord, Project};

/// `alloy docs --agents [--output FILE]`.
///
/// Writes to `output` when given, otherwise prints to stdout. The `json` flag is
/// accepted for interface consistency but this command always emits Markdown.
pub fn agents(api: &dyn Api, output: Option<&Path>, _json: bool) -> Result<i32> {
    let project = api.get_project()?;
    let charter = api.get_charter()?;
    let records = api.list_intents()?;
    let content = render(&project, &charter, &records);

    match output {
        Some(path) => {
            std::fs::write(path, &content)
                .with_context(|| format!("could not write {}", path.display()))?;
            println!("Wrote agent docs to {}", path.display());
        }
        None => print!("{content}"),
    }

    Ok(0)
}

fn render(project: &Project, charter: &Charter, records: &[IntentRecord]) -> String {
    let mut out = String::new();

    out.push_str(&format!(
        "# Working with Alloy in {name} ({key})\n\n",
        name = project.name,
        key = project.key,
    ));
    out.push_str(
        "Alloy captures **engineering intent** as records of the form:\n\n\
         > We need to preserve this *capability* because this *threat* matters under this\n\
         > *expectation*, so we prefer this *strategy*, require this *evidence*, and accept\n\
         > this *tradeoff*.\n\n\
         Use the `alloy` CLI (configured via `.alloy_env`) to read and evolve these records.\n\n",
    );

    out.push_str("## The six fields\n\n");
    out.push_str(
        "- **capability** — the ability the system or team must retain\n\
         - **threat** — the force that erodes that capability\n\
         - **expectation** — the future change/pressure that makes the threat matter\n\
         - **strategy** — the approach that protects the capability\n\
         - **evidence** — observable proof the strategy is working\n\
         - **tradeoff** — the cost the strategy introduces (not optional — it keeps the\n\
         \x20 record honest)\n\n\
         Each record is keyed `<project_key>.intent.<slug>`; the slug is lowercase\n\
         `[a-z0-9_-]+`, derived from the title, and immutable after creation.\n\n",
    );

    out.push_str("## Common commands\n\n");
    out.push_str(
        "```bash\n\
         alloy intent list                       # list this project's intent records\n\
         alloy intent show <slug>                # show one record\n\
         alloy intent create --title \"...\"       # add a record (slug derived from title)\n\
         alloy intent update <slug> --strategy \"...\"\n\
         alloy intent accept|activate|deprecate|contradict <slug>\n\
         alloy intent supersede <slug> --by <replacement-slug>\n\
         alloy charter show                      # the product charter grounding this work\n\
         alloy validate                          # check referential integrity\n\
         ```\n\n",
    );

    out.push_str("## Lifecycle\n\n");
    out.push_str(
        "Records move `hypothesized`/`proposed` → `accepted` → `active`, and may be\n\
         `deprecated`, `contradicted`, or `superseded`. The last two are terminal.\n\n",
    );

    out.push_str(&charter_section(charter));
    out.push('\n');
    out.push_str(&intent_section(records));

    out
}

fn intent_section(records: &[IntentRecord]) -> String {
    let binding: Vec<&IntentRecord> = records
        .iter()
        .filter(|r| matches!(r.status.as_str(), "accepted" | "active"))
        .collect();

    let mut out = String::from("## Engineering intent records\n\n");
    if binding.is_empty() {
        out.push_str(
            "No accepted or active intent records yet. Capture judgment with\n\
             `alloy intent create` and drive records to `accepted`/`active` so this\n\
             projection carries binding guidance.\n",
        );
        return out;
    }

    out.push_str(
        "These records bind autonomous engineering work in this project. Each reads:\n\
         preserve the *capability* because the *threat* matters under the *expectation*;\n\
         prefer the *strategy*, require the *evidence*, accept the *tradeoff*.\n\n",
    );

    for record in binding {
        out.push_str(&format!(
            "### {title} (`{key}`)\n\n",
            title = record.title,
            key = record.key,
        ));
        let fields: [(&str, &Option<String>); 6] = [
            ("Capability", &record.capability),
            ("Threat", &record.threat),
            ("Expectation", &record.expectation),
            ("Strategy", &record.strategy),
            ("Evidence", &record.evidence_summary),
            ("Tradeoff", &record.tradeoff),
        ];
        for (label, value) in fields {
            let rendered = value
                .as_deref()
                .map(str::trim)
                .filter(|v| !v.is_empty())
                .unwrap_or("_(not captured)_");
            out.push_str(&format!("- **{label}:** {rendered}\n"));
        }
        out.push('\n');
    }

    // Drop the trailing blank line so the document ends with a single newline.
    out.truncate(out.trim_end().len());
    out.push('\n');
    out
}

fn charter_section(charter: &Charter) -> String {
    if !charter.present() {
        return "## Product charter\n\nNo charter set yet. Run `alloy charter set --mission \"...\"` \
                to establish the product context that grounds this project's intent.\n"
            .to_string();
    }

    let mut out = String::from("## Product charter\n\n");
    for (field, value) in charter.fields() {
        if let Some(v) = value.as_ref().filter(|s| !s.trim().is_empty()) {
            out.push_str(&format!("- **{}**: {}\n", label(field), v));
        }
    }
    out
}

fn label(field: &str) -> &str {
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
    use crate::api::IntentRecord;

    fn project() -> Project {
        Project {
            key: "acme".into(),
            name: "Acme".into(),
            inserted_at: None,
            updated_at: None,
        }
    }

    fn record(slug: &str, status: &str) -> IntentRecord {
        IntentRecord {
            key: format!("acme.intent.{slug}"),
            project_key: "acme".into(),
            slug: slug.into(),
            title: format!("Title for {slug}"),
            capability: Some(format!("{slug} capability")),
            threat: Some(format!("{slug} threat")),
            expectation: Some(format!("{slug} expectation")),
            strategy: Some(format!("{slug} strategy")),
            evidence_summary: Some(format!("{slug} evidence")),
            tradeoff: Some(format!("{slug} tradeoff")),
            status: status.into(),
            confidence: Some(1.0),
            version: Some(1),
            scope: None,
            supersedes_id: None,
            supersedes_slug: None,
            inserted_at: None,
            updated_at: None,
        }
    }

    #[test]
    fn render_includes_project_and_commands() {
        let doc = render(&project(), &Charter::default(), &[]);
        assert!(doc.contains("Working with Alloy in Acme (acme)"));
        assert!(doc.contains("alloy intent list"));
        assert!(doc.contains("## The six fields"));
        assert!(doc.contains("<project_key>.intent.<slug>"));
        assert!(doc.contains("No charter set yet"));
    }

    #[test]
    fn render_weaves_in_charter_when_present() {
        let charter = Charter {
            mission: Some("Preserve intent".into()),
            ..Default::default()
        };
        let doc = render(&project(), &charter, &[]);
        assert!(doc.contains("**Mission**: Preserve intent"));
    }

    #[test]
    fn render_includes_accepted_and_active_records_with_all_six_fields() {
        let doc = render(
            &project(),
            &Charter::default(),
            &[record("first", "active"), record("second", "accepted")],
        );
        assert!(doc.contains("## Engineering intent records"));
        assert!(doc.contains("### Title for first (`acme.intent.first`)"));
        assert!(doc.contains("### Title for second (`acme.intent.second`)"));
        assert!(doc.contains("- **Capability:** first capability"));
        assert!(doc.contains("- **Threat:** first threat"));
        assert!(doc.contains("- **Expectation:** first expectation"));
        assert!(doc.contains("- **Strategy:** first strategy"));
        assert!(doc.contains("- **Evidence:** first evidence"));
        assert!(doc.contains("- **Tradeoff:** first tradeoff"));
    }

    #[test]
    fn render_excludes_records_outside_accepted_and_active() {
        let doc = render(
            &project(),
            &Charter::default(),
            &[
                record("kept", "accepted"),
                record("draft", "proposed"),
                record("guessed", "hypothesized"),
                record("retired", "deprecated"),
                record("wrong", "contradicted"),
                record("replaced", "superseded"),
            ],
        );
        assert!(doc.contains("acme.intent.kept"));
        for slug in ["draft", "guessed", "retired", "wrong", "replaced"] {
            assert!(!doc.contains(&format!("acme.intent.{slug}")), "{slug}");
        }
    }

    #[test]
    fn render_marks_missing_intent_fields_as_not_captured() {
        let sparse = IntentRecord {
            capability: None,
            threat: Some("  ".into()),
            ..record("sparse", "active")
        };
        let doc = render(&project(), &Charter::default(), &[sparse]);
        assert!(doc.contains("- **Capability:** _(not captured)_"));
        assert!(doc.contains("- **Threat:** _(not captured)_"));
        assert!(doc.contains("- **Strategy:** sparse strategy"));
    }

    #[test]
    fn render_notes_when_no_binding_records_exist() {
        let doc = render(
            &project(),
            &Charter::default(),
            &[record("draft", "proposed")],
        );
        assert!(doc.contains("No accepted or active intent records yet"));
    }
}
