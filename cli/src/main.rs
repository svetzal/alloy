//! The `alloy` binary: parses arguments, builds the HTTP gateway from
//! `.alloy_env`, dispatches to a command, and maps the result to an exit code.

use std::path::PathBuf;
use std::process::ExitCode;

use anyhow::Result;
use clap::{Args, Parser, Subcommand};

use alloy_cli::api::{Api, Transition};
use alloy_cli::commands::{charter, docs, intent, project, validate};
use alloy_cli::config::Config;
use alloy_cli::http::HttpApi;
use alloy_cli::output::emit_error;

#[derive(Parser)]
#[command(
    name = "alloy",
    version,
    about = "Thin-client CLI for the Alloy engineering-intent backend",
    propagate_version = true
)]
struct Cli {
    /// Emit machine-readable JSON ({success, data, error}).
    #[arg(long, global = true)]
    json: bool,

    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Inspect or rename the token-scoped project.
    Project {
        #[command(subcommand)]
        action: ProjectAction,
    },
    /// Show or set the project's product charter.
    Charter {
        #[command(subcommand)]
        action: CharterAction,
    },
    /// Work with engineering intent records.
    Intent {
        #[command(subcommand)]
        action: IntentAction,
    },
    /// Check the project's referential integrity (exit 1 on errors).
    Validate,
    /// Generate agent-facing documentation for this project.
    Docs(DocsArgs),
}

#[derive(Subcommand)]
enum ProjectAction {
    /// Show the current project.
    Show,
    /// Rename the current project.
    Set {
        /// The new display name.
        #[arg(long)]
        name: String,
    },
}

#[derive(Subcommand)]
enum CharterAction {
    /// Show the product charter.
    Show,
    /// Set one or more charter fields (others are left untouched).
    Set(CharterSetArgs),
}

#[derive(Args)]
struct CharterSetArgs {
    /// Why the product exists.
    #[arg(long)]
    mission: Option<String>,
    /// Who it serves.
    #[arg(long)]
    target_audience: Option<String>,
    /// The problem it addresses.
    #[arg(long)]
    problem_space: Option<String>,
    /// What sets it apart.
    #[arg(long)]
    differentiators: Option<String>,
    /// What it deliberately does not do.
    #[arg(long)]
    out_of_scope: Option<String>,
}

#[derive(Subcommand)]
enum IntentAction {
    /// List this project's intent records.
    List,
    /// Show one intent record by slug.
    Show { slug: String },
    /// Create an intent record (slug derived from the title when omitted).
    Create(IntentCreateArgs),
    /// Update fields on an intent record.
    Update(IntentUpdateArgs),
    /// Remove an intent record.
    Remove { slug: String },
    /// Accept a hypothesized/proposed record.
    Accept { slug: String },
    /// Activate an accepted record.
    Activate { slug: String },
    /// Deprecate an accepted/active record.
    Deprecate { slug: String },
    /// Mark a record contradicted (terminal).
    Contradict { slug: String },
    /// Mark a record superseded (terminal), optionally linking its replacement.
    Supersede {
        slug: String,
        /// The slug of the record that replaces this one.
        #[arg(long)]
        by: Option<String>,
    },
}

#[derive(Args)]
struct IntentCreateArgs {
    /// The record's title (required).
    #[arg(long)]
    title: String,
    /// An explicit slug; derived from the title when omitted.
    #[arg(long)]
    slug: Option<String>,
    #[command(flatten)]
    fields: IntentFieldArgs,
}

#[derive(Args)]
struct IntentUpdateArgs {
    /// The slug of the record to update.
    slug: String,
    /// A new title.
    #[arg(long)]
    title: Option<String>,
    #[command(flatten)]
    fields: IntentFieldArgs,
}

/// The intent fields shared by create and update.
#[derive(Args)]
struct IntentFieldArgs {
    /// The ability to retain.
    #[arg(long)]
    capability: Option<String>,
    /// The force that erodes it.
    #[arg(long)]
    threat: Option<String>,
    /// The change that makes it matter.
    #[arg(long)]
    expectation: Option<String>,
    /// The approach that protects it.
    #[arg(long)]
    strategy: Option<String>,
    /// Observable proof it is working.
    #[arg(long)]
    evidence_summary: Option<String>,
    /// The cost the strategy introduces.
    #[arg(long)]
    tradeoff: Option<String>,
    /// Lifecycle status (e.g. hypothesized, proposed, accepted, active).
    #[arg(long)]
    status: Option<String>,
    /// Confidence in [0.0, 1.0].
    #[arg(long)]
    confidence: Option<f64>,
}

#[derive(Args)]
struct DocsArgs {
    /// Generate agent-facing guidance (currently the only docs mode).
    #[arg(long)]
    agents: bool,
    /// Write to this file instead of stdout.
    #[arg(long)]
    output: Option<PathBuf>,
}

impl IntentCreateArgs {
    fn into_fields(self) -> intent::IntentFields {
        let mut fields = self.fields.into_fields();
        fields.title = Some(self.title);
        fields.slug = self.slug;
        fields
    }
}

impl IntentUpdateArgs {
    fn into_fields(self) -> intent::IntentFields {
        let mut fields = self.fields.into_fields();
        fields.title = self.title;
        fields
    }
}

impl IntentFieldArgs {
    fn into_fields(self) -> intent::IntentFields {
        intent::IntentFields {
            title: None,
            slug: None,
            capability: self.capability,
            threat: self.threat,
            expectation: self.expectation,
            strategy: self.strategy,
            evidence_summary: self.evidence_summary,
            tradeoff: self.tradeoff,
            status: self.status,
            confidence: self.confidence,
        }
    }
}

impl CharterSetArgs {
    fn into_fields(self) -> charter::CharterFields {
        charter::CharterFields {
            mission: self.mission,
            target_audience: self.target_audience,
            problem_space: self.problem_space,
            differentiators: self.differentiators,
            out_of_scope: self.out_of_scope,
        }
    }
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    let json = cli.json;

    match run(cli) {
        Ok(code) => ExitCode::from(code as u8),
        Err(err) => {
            emit_error(json, &format!("{err:#}"));
            ExitCode::from(1)
        }
    }
}

fn run(cli: Cli) -> Result<i32> {
    let json = cli.json;
    let api = HttpApi::new(Config::load()?)?;
    dispatch(&api, json, cli.command)
}

fn dispatch(api: &dyn Api, json: bool, command: Command) -> Result<i32> {
    match command {
        Command::Project { action } => match action {
            ProjectAction::Show => project::show(api, json),
            ProjectAction::Set { name } => project::set(api, json, &name),
        },
        Command::Charter { action } => match action {
            CharterAction::Show => charter::show(api, json),
            CharterAction::Set(args) => charter::set(api, json, args.into_fields()),
        },
        Command::Intent { action } => dispatch_intent(api, json, action),
        Command::Validate => validate::run(api, json),
        Command::Docs(args) => {
            if !args.agents {
                anyhow::bail!("specify a docs mode, e.g. `alloy docs --agents`");
            }
            docs::agents(api, args.output.as_deref(), json)
        }
    }
}

fn dispatch_intent(api: &dyn Api, json: bool, action: IntentAction) -> Result<i32> {
    match action {
        IntentAction::List => intent::list(api, json),
        IntentAction::Show { slug } => intent::show(api, json, &slug),
        IntentAction::Create(args) => intent::create(api, json, args.into_fields()),
        IntentAction::Update(args) => {
            let slug = args.slug.clone();
            intent::update(api, json, &slug, args.into_fields())
        }
        IntentAction::Remove { slug } => intent::remove(api, json, &slug),
        IntentAction::Accept { slug } => intent::transition(api, json, &slug, Transition::Accept),
        IntentAction::Activate { slug } => {
            intent::transition(api, json, &slug, Transition::Activate)
        }
        IntentAction::Deprecate { slug } => {
            intent::transition(api, json, &slug, Transition::Deprecate)
        }
        IntentAction::Contradict { slug } => {
            intent::transition(api, json, &slug, Transition::Contradict)
        }
        IntentAction::Supersede { slug, by } => intent::supersede(api, json, &slug, by.as_deref()),
    }
}
