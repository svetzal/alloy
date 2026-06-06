---
name: alloy
description: Use Alloy (the `alloy` CLI) to capture and refine engineering intent as six-field records — capability, threat, expectation, strategy, evidence, tradeoff. Use this skill whenever the user mentions engineering intent, intent records, capability/threat/expectation/strategy/evidence/tradeoff, why a design decision was made, preserving an architectural capability, a product charter, the Foundry execution engine, or any `alloy` CLI commands. Also use when the user wants to record the reasoning behind an engineering judgement so agents can preserve it.
metadata:
  author: Stacey Vetzal
---

# Alloy — Capturing Engineering Intent

Alloy (`alloy`) is a CLI that records **engineering intent**: the future-facing
judgements behind a codebase, so that humans and agents can preserve them as the
code evolves. It sits above the Rust "Foundry" execution engine — Alloy holds
*why* the system is the way it is; Foundry acts on it. This skill teaches the
intent model and the `alloy` CLI; the CLI is a thin client over an Alloy backend.

## Philosophy

Code records *what* a system does, and tests record *that it works*. Neither
records *why* it was built that way — the capability worth keeping, the threat
that erodes it, the pressure that makes the threat matter. That reasoning is
**engineering intent**, and it evaporates first: the original author moves on, an
agent refactors past a boundary that existed for a reason, a "cleanup" deletes
the one seam that made the system replaceable.

An Engineering Intent Record captures one such judgement as a single sentence:

> We need to preserve this **capability** because this **threat** matters under
> this **expectation**, so we prefer this **strategy**, require this
> **evidence**, and accept this **tradeoff**.

The six fields keep the judgement specific and checkable. A record is not
documentation prose — it is a structured claim with a lifecycle, because
extracted intent is often a *hypothesis*, not a settled fact.

**The first question** before recording intent: *what capability would be lost,
and under what future pressure, if no one knew this reasoning?* If you cannot
name the capability and the threat, you have a task or a note, not an intent
record.

## Setup

### `.alloy_env` configuration

The `alloy` CLI is a thin client. It reads a single `.alloy_env` file from the
**current working directory only** — it does **not** walk up the directory tree.
The file holds the backend URL and a per-project bearer token:

```
ALLOY_API_HOST=https://alloy.example.com
ALLOY_API_TOKEN=alloy_your-token-here
```

> **IMPORTANT:** `.alloy_env` contains a secret token. It is gitignored and must
> never be committed.

Mint a token in the Alloy web console (**Projects → a project → Generate
token**); the console shows a ready-to-paste `.alloy_env` snippet once. The token
*identifies the project*, so CLI commands never name a project — the configured
token scopes everything to one.

**You MUST run `alloy` from the project root** where `.alloy_env` lives. If a
command returns "No `.alloy_env` found" or empty results unexpectedly, the
working directory is almost certainly wrong.

### Install the skill files

Run `alloy init` to install (or update) these skill files into
`.claude/skills/alloy/`. This is how the file you are reading was installed. Run
it again after upgrading the `alloy` binary to refresh the guidance.

```bash
alloy init            # install into ./.claude/skills/alloy/
alloy init --global   # install into ~/.claude/skills/alloy/
alloy init --json
```

Each file is stamped with the binary's version (`alloy_version` in frontmatter).
`init` refuses to overwrite a *newer* installed skill unless you pass `--force`.

### Always use `--json` for agent interactions

`--json` makes every command emit the shared `{success, data, error}` envelope,
which is stable and parseable. Always pass it when driving the CLI as an agent:

```bash
alloy intent list --json
alloy intent show <slug> --json
```

Exit code is `0` on success and `1` on failure (and `1` from `validate` when it
finds any error-level issue).

## The product charter

Each project has a **charter** — five free-text fields describing what the
product is and is not. Read it first when you encounter a project: it grounds
which capabilities matter and which intent is in scope.

```bash
alloy charter show --json
alloy charter set --mission "Preserve engineering intent across change" --json
```

| Field | Flag | Purpose |
|-------|------|---------|
| Mission | `--mission` | Why the product exists |
| Target audience | `--target-audience` | Who it serves |
| Problem space | `--problem-space` | The problem it addresses |
| Differentiators | `--differentiators` | What sets it apart |
| Out of scope | `--out-of-scope` | What it deliberately does **not** do |

`charter set` is a **partial upsert**: setting one field leaves the others
untouched. Passing an empty string to a field clears it.

## The Engineering Intent Record

Every record decomposes one engineering judgement into six fields:

| Field | Flag | What it captures |
|-------|------|------------------|
| **Capability** | `--capability` | The ability the system or team must retain |
| **Threat** | `--threat` | The force that erodes that capability |
| **Expectation** | `--expectation` | The future change/pressure that makes the threat matter |
| **Strategy** | `--strategy` | The technical or social approach that protects the capability |
| **Evidence** | `--evidence-summary` | Observable proof the strategy is working |
| **Tradeoff** | `--tradeoff` | The cost or failure mode the strategy introduces |

The **tradeoff is not optional polish** — it is what stops a record from reading
as dogma and keeps it falsifiable. A strategy with no acknowledged cost is a
slogan, not a judgement.

A record also carries a `title`, a project-local `slug` (its key within the
project), a `status` (lifecycle, below), and a `confidence` in `[0.0, 1.0]`.

See [references/intent-model.md](references/intent-model.md) for field-by-field
examples drawn from real projects.

## Keys and identifiers

- A record's **slug** is its identifier within a project: lowercase letters,
  numbers, underscores, and hyphens (`^[a-z0-9_-]+$`). It is derived from the
  title when you omit `--slug`, and is **immutable after creation**.
- The CLI addresses records by slug (`alloy intent show <slug>`), because the
  configured token already scopes to one project.
- The fully-qualified key is `<project_key>.intent.<slug>` — e.g.
  `alloy.intent.preserve-testability`. Use the full key when referring to a
  record across projects (e.g. in prose or AGENTS.md).

## Lifecycle

A record is a hypothesis until a human confirms it, so it moves through states:

```
hypothesized ─┐
              ├─accept─▶ accepted ─activate─▶ active
proposed ─────┘            │                    │
                           └────────deprecate───┴─▶ deprecated
any non-terminal ─contradict─▶ contradicted   (terminal)
any non-terminal ─supersede──▶ superseded     (terminal)
```

| Status | Meaning |
|--------|---------|
| `hypothesized` | Extracted by tooling; a human has not confirmed it |
| `proposed` | Drafted and ready for review (the default on create) |
| `accepted` | A qualified human confirmed it should guide work |
| `active` | Accepted and currently used to guide work |
| `deprecated` | No longer generally applicable, but its history is useful |
| `contradicted` | Shown to be untrue or conflicting — **terminal** |
| `superseded` | Replaced by a newer record — **terminal** |

Transition commands move a record along this machine; an illegal transition is
rejected (e.g. you cannot `activate` a `proposed` record without accepting it
first). `contradicted` and `superseded` are terminal — a record in either state
can no longer transition.

```bash
alloy intent accept <slug> --json
alloy intent activate <slug> --json
alloy intent deprecate <slug> --json
alloy intent contradict <slug> --json
alloy intent supersede <slug> --by <replacement-slug> --json
```

`supersede --by` links the replacement record, recording lineage.

## Core workflow

1. **Read the charter** (first time, or when unsure about scope):
   ```bash
   alloy charter show --json
   ```
2. **Review existing intent** before adding more:
   ```bash
   alloy intent list --json
   ```
3. **Capture a judgement** as a record (slug derived from the title):
   ```bash
   alloy intent create \
     --title "Preserve domain testability" \
     --capability "Business rules can be tested without DB, UI, or network" \
     --threat "Logic leaking into LiveView handlers and Ecto callbacks" \
     --expectation "Agents will make frequent changes to the web layer" \
     --strategy "Functional core / imperative shell; gateways behind behaviours" \
     --evidence-summary "Core test suite runs with no database started" \
     --tradeoff "Indirection can feel heavy for simple CRUD" \
     --json
   ```
4. **Refine** as understanding sharpens:
   ```bash
   alloy intent update preserve-domain-testability --confidence 0.9 --json
   ```
5. **Confirm and activate** once a human agrees it should guide work:
   ```bash
   alloy intent accept preserve-domain-testability --json
   alloy intent activate preserve-domain-testability --json
   ```
6. **Retire** when reality changes — `deprecate`, `contradict`, or `supersede`.
7. **Validate** referential integrity:
   ```bash
   alloy validate --json
   ```

## Essential commands

```bash
# Project (token-scoped — no project id needed)
alloy project show --json
alloy project set --name "New display name" --json

# Charter (partial upsert)
alloy charter show --json
alloy charter set --mission "..." --out-of-scope "..." --json

# Intent records
alloy intent list --json
alloy intent show <slug> --json
alloy intent create --title "..." [--capability ... --threat ... ...] --json
alloy intent update <slug> [--strategy "..." --confidence 0.8 ...] --json
alloy intent remove <slug> --json

# Lifecycle transitions
alloy intent accept|activate|deprecate|contradict <slug> --json
alloy intent supersede <slug> --by <replacement-slug> --json

# Integrity + agent docs
alloy validate --json
alloy docs --agents [--output AGENTS-alloy.md]
```

`alloy docs --agents` generates project-specific agent guidance with the live
charter woven in — write it into the repo so other agents inherit the context.

## When work has no preservable intent

Not every change deserves a record. Before creating one, ask whether a real
capability would be *lost under future pressure* if the reasoning were forgotten.
A reformat, a typo fix, or a dependency bump usually has no intent to preserve. A
boundary, a seam, an error-handling contract, or a deliberate constraint usually
does. When unsure, draft it as `proposed` and let a human accept or discard it.

## Supporting files

- **Complete CLI reference** (every command, flag, exit code, envelope):
  [references/cli-reference.md](references/cli-reference.md)
- **The intent model in depth** (six fields with examples, lifecycle rules, key
  scheme): [references/intent-model.md](references/intent-model.md)
- **Getting started in a new project**:
  [workflows/getting-started.md](workflows/getting-started.md)
- **Turning a judgement into a record**:
  [workflows/capturing-intent.md](workflows/capturing-intent.md)
