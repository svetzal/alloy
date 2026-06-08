# `alloy` CLI Reference

Complete reference for every `alloy` command, flag, and option. For the concepts
behind these commands, see [intent-model.md](intent-model.md); for setup, see
the Setup section of `../SKILL.md`.

## Global behaviour

| Flag | Purpose |
|------|---------|
| `--json` | Emit the machine-readable `{success, data, error}` envelope. Always use for agent interactions. |
| `--help` | Show help for the binary or a subcommand. |
| `--version` | Show the `alloy` version. |

`--json` is a global flag: it may appear anywhere on the command line and
applies to whichever subcommand runs.

### Configuration

Every command except `alloy init` reads `.alloy_env` from the **current working
directory** (no parent-directory walk):

```
ALLOY_API_HOST=https://alloy.example.com
ALLOY_API_TOKEN=alloy_your-token-here
```

The token scopes all commands to a single project, so no command takes a project
identifier. A missing or incomplete `.alloy_env` produces an actionable error.

### Response envelope (`--json`)

Success:

```json
{ "success": true, "data": { /* resource(s) */ }, "error": null }
```

Failure:

```json
{ "success": false, "data": null, "error": { "message": "…", "code": "…" } }
```

`code` and `details` on the error are optional. Without `--json`, success prints
a human rendering to stdout and failure prints `Error: …` to stderr.

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success. |
| `1` | Any failure (bad config, API error, not found), or `validate` finding ≥1 error-level issue. |

## `alloy init`

Install or update the agent skill files embedded in the binary.

```bash
alloy init [--global] [--force] [--json]
```

| Flag | Purpose |
|------|---------|
| `--global` | Install into `~/.claude/skills/alloy/` instead of `./.claude/skills/alloy/`. |
| `--force` | Overwrite even when the installed skill is from a newer `alloy` version (a downgrade). |

`init` requires **no** `.alloy_env` — it only writes files. Each file is stamped
with the binary's version (`alloy_version` in frontmatter). On re-run, files
unchanged since install report `up-to-date`; changed source reports `updated`;
a newer installed version is `skipped` unless `--force`.

## `alloy project`

The project is identified by the configured token.

```bash
alloy project show [--json]            # show the current project
alloy project set --name "<name>" [--json]   # rename the current project
```

`project set` requires `--name`. Project creation and deletion are web-console
concerns, not CLI commands.

## `alloy charter`

The product charter: five free-text fields, one charter per project.

```bash
alloy charter show [--json]
alloy charter set [field flags…] [--json]
```

### `charter set` field flags

| Flag | Field |
|------|-------|
| `--mission` | Mission |
| `--target-audience` | Target audience |
| `--problem-space` | Problem space |
| `--differentiators` | Differentiators |
| `--out-of-scope` | Out of scope |

`charter set` is a **partial upsert**: only the fields you pass are written;
omitted fields keep their current values. Passing an empty string (`--mission
""`) clears that field. At least one field flag should be supplied.

## `alloy intent`

Engineering intent records, addressed by their project-local `slug`.

### `intent list`

```bash
alloy intent list [--json]
```

Lists every record in the project with its slug, title, and status.

### `intent show`

```bash
alloy intent show <slug> [--json]
```

Shows one record's full six-field content, status, confidence, and lineage.

### `intent create`

```bash
alloy intent create --title "<title>" [field flags…] [--json]
```

| Flag | Required | Description |
|------|----------|-------------|
| `--title` | Yes | The record's title. |
| `--slug` | No | Explicit slug; derived from the title when omitted. Immutable after creation. |
| `--capability` | No | The ability to retain. |
| `--threat` | No | The force that erodes it. |
| `--expectation` | No | The change that makes it matter. |
| `--strategy` | No | The approach that protects it. |
| `--evidence-summary` | No | Observable proof it is working. |
| `--tradeoff` | No | The cost the strategy introduces. |
| `--status` | No | Initial lifecycle status (default `proposed`). |
| `--confidence` | No | Float in `[0.0, 1.0]`. |

### `intent update`

```bash
alloy intent update <slug> [--title "…"] [field flags…] [--json]
```

Accepts the same field flags as `create` (except `--slug`, which is immutable).
Only the flags you pass are changed.

### `intent remove`

```bash
alloy intent remove <slug> [--json]
```

Deletes the record.

### Lifecycle transitions

```bash
alloy intent accept <slug> [--json]       # hypothesized|proposed → accepted
alloy intent activate <slug> [--json]     # accepted → active
alloy intent deprecate <slug> [--json]    # accepted|active → deprecated
alloy intent contradict <slug> [--json]   # any non-terminal → contradicted (terminal)
alloy intent supersede <slug> [--by <replacement-slug>] [--json]
                                          # any non-terminal → superseded (terminal)
```

`supersede --by <slug>` links the replacement record. An illegal transition
(e.g. activating a record that has not been accepted) is rejected with a `422`
and a descriptive message; the record is unchanged.

## `alloy validate`

```bash
alloy validate [--json]
```

Checks the project's referential integrity and reports `errors` and `warnings`.
Exits `1` when any error-level issue is found, `0` otherwise. See
[intent-model.md](intent-model.md) for the integrity rules.

## `alloy docs`

```bash
alloy docs --agents [--output <FILE>]
```

Generates agent-facing Markdown guidance for working with Alloy in this project,
with the live charter woven in. Prints to stdout, or writes to `--output` when
given. Always emits Markdown (the `--json` flag does not change its output).
`--agents` is currently the only mode.
