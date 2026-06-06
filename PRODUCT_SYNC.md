# Product Sync — Bringing Alloy to Epilogue Tracker Baseline Parity

This is a working implementation plan, not product spec. The authoritative
domain spec lives in `docs/` (read-only). This document tracks the baseline
infrastructure work needed to make Alloy operate like its sibling product
[Epilogue Tracker](https://github.com/) (`et`) — multiple projects, namespaced
keys, a per-project charter, a JSON API, a thin-client CLI, and a corresponding
Claude Code skill — with the CLI implemented in **Rust** rather than
TypeScript.

## Reference model: how Epilogue Tracker works

Epilogue Tracker (at `~/Work/Projects/Mojility/epilogue-tracker`) establishes
the baseline pattern we are replicating:

- **Phoenix web app backend** owns all data in Postgres.
- **Thin-client CLI** (`et`, TS/Bun, compiled to per-platform binaries) talks
  to the backend over a REST API. It holds no local data.
- **Per-project config** is a single `.et_env` file in the project root
  (`ET_API_HOST`, `ET_API_TOKEN`), read from `cwd` with no directory-tree walk,
  and gitignored because it holds a secret. "Multiple projects" on the client
  is simply one `.et_env` per directory.
- **Product charter** stored server-side: `mission`, `target_audience`,
  `problem_space`, `differentiators`, `out_of_scope`; edited via
  `et charter set --field`.
- **User-provided keys**: entity IDs match `^[a-zA-Z0-9_-]+$`, snake_case by
  convention, referenced directly between entities.
- **Embedded agent skill**: `SKILL.md` + `references/` + `workflows/`, installed
  via `et init [--global]`, version-stamped in frontmatter (`et_version`). The
  skill *teaches* the CLI; it does not shell out on its own.
- **Conventions**: `--json` on every command, `{success, data, error}` response
  envelope, exit codes, a `validate` command for referential integrity, and a
  `docs --agents` generator.

## Current Alloy state

- First domain slice only: `engineering_intent_records` (schema, `Alloy.Intent`
  context, LiveView CRUD). Records use UUID primary keys.
- No `projects` table — although the data model in `docs/` lists `project_id`
  on most entities. The intent record carries a loose `scope` jsonb holding a
  `"project"` string.
- No JSON API (the router's `:api` pipeline exists but is unused), no API
  tokens, no auth.
- No product charter.
- No CLI, no agent skill.

## Approved decisions (2026-06-06)

| Decision | Choice |
| -------- | ------ |
| CLI language | **Rust** (cargo crate) |
| CLI location | **In this repo**, `cli/` crate (monorepo, like et's `apps/cli`) |
| CLI transport | **HTTP API parity** — thin client over a new Phoenix JSON API + per-project bearer token in `.alloy_env` |
| Keys | **Both** — namespaced entity keys (`project.intent.slug`) **and** per-project API tokens |
| Charter | **Alloy-native, one per project**, with et's five fields |

The `.alloy/` file projection for Foundry is a **separate, later concern** —
not part of this baseline.

## Gap list

Each item: what et establishes → what Alloy has today → the gap to close.

### Backend (Phoenix)

1. **Projects as a first-class entity (multi-project)**
   - *et:* backend owns "products"; client multi-project is one `.et_env` per dir.
   - *Alloy:* data model lists `project_id` but there is no projects
     table/schema/context; intent records hold only a `scope.project` string.
   - *Gap:* `projects` table + `Alloy.Projects` context + `Project` schema
     (unique `key` slug, `name`, timestamps); relational `project_id` FK on
     `engineering_intent_records` (migrating off the loose `scope.project`
     string); Projects LiveView + a project switcher; project-scoped intent
     LiveViews.

2. **Keys / identifiers ("build keys for a project")**
   - *et:* user-provided IDs, `^[a-zA-Z0-9_-]+$`, snake_case, no namespacing.
   - *Alloy:* UUID PKs only; the spec's JSON shape shows `alloy.intent.example`
     but nothing generates it.
   - *Gap:* a unique project `key`/slug; a stable, human-readable record key
     namespaced by project (`<project_key>.intent.<slug>`); derivation rules,
     a validation regex (`^[a-z0-9_-]+$`), uniqueness, and immutability after
     creation. Plus per-project **API tokens** (see item 3).

3. **JSON API + token auth (the CLI's backend)**
   - *et:* CLI hits `${HOST}/api/...` with a bearer token; `{success, data,
     error}` envelope; lifecycle transition endpoints.
   - *Alloy:* only `/` + LiveViews; `:api` pipeline unused; no controllers, no
     tokens.
   - *Gap:* `/api/v1` controllers for projects + intent records (CRUD **and**
     the lifecycle transitions already modeled — accept/activate/supersede/
     contradict) + charter; an `api_tokens` table (per project) + bearer-auth
     plug; the shared response envelope.

4. **Product charter**
   - *et:* server-side charter, five fields, `et charter [set --field]`.
   - *Alloy:* no charter concept.
   - *Gap:* a `charters` table (one per project; `mission`, `target_audience`,
     `problem_space`, `differentiators`, `out_of_scope`) + context + LiveView +
     API endpoint + CLI command. *Spec note:* Alloy's spec frames product intent
     as flowing in from Epilogue Tracker; we are choosing an Alloy-native
     charter regardless, to satisfy "hold a product charter" directly.

### CLI (Rust `alloy`)

1. **The Rust CLI itself**
   - *et:* `et` (Bun/TS) → per-platform binaries; `--json` everywhere; exit
     codes; `validate`; `docs --agents`; `init`.
   - *Alloy:* none.
   - *Gap:* a Rust crate (clap + reqwest + serde) with subcommands mirroring
     et — `init`, `projects`, `intent create/list/show/update/remove` +
     lifecycle transitions, `charter [set]`, `validate`, `docs --agents`;
     `--json` + exit codes; cross-compiled release binaries.

2. **Per-project CLI config + gitignore**
   - *et:* `.et_env` (KEY=VALUE) in `cwd`, no dir-tree walk, gitignored.
   - *Alloy:* none.
   - *Gap:* an `.alloy_env` analog (`ALLOY_API_HOST`, `ALLOY_API_TOKEN`), a
     loader, a gitignore entry, and a web-UI flow to mint a project token to
     paste in.

### Agent skill

1. **`alloy` skill, installed by the CLI**
   - *et:* skill embedded in the binary, installed via `et init [--global]`,
     version-stamped; `SKILL.md` + `references/` + `workflows/`; teaches the CLI.
   - *Alloy:* repo docs exist, but no agent skill for any CLI.
   - *Gap:* author `skills/alloy/` (SKILL.md + cli-reference + intent-model +
     workflows) teaching the six-field engineering-intent model, lifecycle, key
     scheme, and charter; `alloy init` installs it via `include_str!`,
     version-stamped (`alloy_version`).

### Cross-cutting parity polish

1. `validate` referential integrity (project exists, `supersedes_id` resolves,
   key uniqueness); `docs --agents` content; skill upgrade/downgrade-guard
   semantics; Rust CI + the API surface folded into the quality gate.

## Phased implementation plan

Each phase lands incrementally on `main` (trunk-based), tests-first, through the
full quality gate.

### Phase 1 — Projects + keys (DB foundation) ✅ Complete

`projects` table/schema/context (unique `key` slug, `name`); add `project_id`
FK + namespaced `key` to `engineering_intent_records` (migrating the loose
`scope.project` string onto the relation); key derivation + validation
(immutable after create); Projects LiveView + a project switcher; make the
intent LiveViews project-scoped.

**Delivered** (trunk-based on `main`, full quality gate + dialyzer green):

- `38e4595` — `Alloy.Slug` (pure slugify/validation); `projects` table +
  `Alloy.Projects.Project` schema (key derived from name, slug-validated,
  immutable after create) + `Alloy.Projects` context.
- `f69fd95` — Projects LiveView CRUD under `/projects` (keyed by slug via
  `Phoenix.Param`); Alloy-branded nav.
- `6e90f64` — intent records related to projects: `project_id` FK +
  immutable project-local `slug` (backfilled off `scope.project`), unique
  `(project_id, slug)` index; `Record.full_key/1` →
  `<project_key>.intent.<slug>`; project-scoped `Alloy.Intent` context;
  intent LiveViews nested under `/projects/:project_key/intents`; nav
  project switcher.

### Phase 2 — JSON API + tokens ✅ Complete

`api_tokens` table (per project), bearer-auth plug, `/api/v1` controllers for
projects + intent records (CRUD and lifecycle transitions), shared
`{success, data, error}` envelope, token-generation UI in the Projects LiveView.

**Delivered** (trunk-based on `main`, full quality gate + dialyzer green):

- `c4cf331` — lifecycle transitions in the Intent core
  (accept/activate/deprecate/contradict/supersede) via a state-machine
  `Record.transition_changeset/2`; `:contradicted`/`:superseded` are terminal;
  `supersede_record/2` can atomically link a replacement.
- `e3e4570` — per-project API tokens: `api_tokens` table +
  `Alloy.Projects.ApiToken` (generate `alloy_<random>`, store only a SHA-256
  hash); `Projects` context create/list/delete + `authenticate_token/1`;
  `AlloyWeb.Plugs.ApiAuth` (Bearer → `conn.assigns.current_project`, 401 on
  failure); `AlloyWeb.Api.Envelope` shared `{success, data, error}` shape.
- `97e4f00` — `/api/v1` JSON controllers: `ProjectController` (show/update the
  token-scoped project) and `IntentRecordController` (CRUD + a `POST` sub-path
  per transition; supersede links a replacement via `{"by": slug}`);
  `FallbackController` maps `{:error, changeset}` → 422 and `nil` → 404; record
  + project JSON serializers; `Intent.get_record_by_slug/2` (non-raising).
- `b732ffe` — token-generation UI in the project Show LiveView: mint a named
  token, reveal its secret once as a ready-to-paste `.alloy_env` snippet, list,
  and revoke.

The bearer token identifies the project, so `/api/v1` routes carry no project
id; project create/delete stay web-UI concerns. Records are addressed by their
project-local slug.

### Phase 3 — Charter ✅ Complete

`charters` table (one per project; five fields), context, LiveView, and a
token-scoped `/api/v1/charter` endpoint.

**Delivered** (trunk-based on `main`, full quality gate + dialyzer green):

- `charters` table (one-per-project via a unique `project_id`; five free-text
  fields: `mission`, `target_audience`, `problem_space`, `differentiators`,
  `out_of_scope`) + `Alloy.Charters.Charter` schema (all fields optional, blank
  strings normalized to `nil`) + `Alloy.Charters` context (`get_charter`,
  `get_or_new_charter`, `upsert_charter`, `present?`, `change_charter`).
- `/api/v1/charter` JSON controller (GET shows the five-field shape — `null`s
  when unset — and PATCH/PUT upserts), sharing the `{success, data, error}`
  envelope and the bearer-token project scoping.
- `CharterLive.Show` at `/projects/:project_key/charter` (display + single-save
  edit form); a charter summary section and Set/Edit button on the project Show
  LiveView.

As with the rest of `/api/v1`, the bearer token identifies the project, so the
charter endpoint carries no project id in its path (the earlier plan's
`/api/v1/projects/:key/charter` sketch is superseded by this Phase 2
convention).

### Phase 4 — Rust CLI (`cli/`) ✅ Complete

clap + reqwest + serde; `.alloy_env` loader (`ALLOY_API_HOST` /
`ALLOY_API_TOKEN`, no dir-tree walk, gitignored); subcommands `init`,
`projects`, `intent create/list/show/update/remove` + transitions,
`charter [set]`, `validate`, `docs --agents`; `--json` + exit codes;
cross-compiled release binaries.

**Delivered** (trunk-based on `main`; `cargo fmt --check`, `cargo clippy
--all-targets -- -D warnings`, and `cargo test` all green; smoke-tested
end-to-end against a running backend):

- `cli/` crate (`alloy-cli`, binary `alloy`) following the repo's
  functional-core / imperative-shell split: command logic is written against an
  `Api` **gateway trait** (`src/api.rs`) and unit-tested with an in-memory fake
  (`src/testsupport.rs`); the real `reqwest` blocking client is the thin
  `HttpApi` in `src/http.rs`.
- `Config` loader for `.alloy_env` (`ALLOY_API_HOST` / `ALLOY_API_TOKEN`, cwd
  only, blank/comment-tolerant, trailing-slash-stripped, actionable error when
  missing); both `cli/target/` and `.alloy_env` added to `.gitignore`.
- Commands: `project show|set`, `charter show|set` (partial upsert — a single
  `--field` does not clear the others), `intent list|show|create|update|remove`
  + `accept|activate|deprecate|contradict|supersede [--by]`, `validate`, and
  `docs --agents [--output]`. Global `--json` emits the shared
  `{success, data, error}` envelope; exit code `0`/`1` (and `1` from `validate`
  on any error-level finding).

**Deviations / sequencing:**

- **`init` + skill embedding moved to Phase 5.** The `init` command's whole
  purpose is to write out the embedded agent skill via `include_str!`, which
  needs the Phase 5 skill *content* to exist. Building it here would mean
  stubbing then rebuilding it, so it lands with the skill in Phase 5.
- **`validate` is intentionally shallow for now** (slug well-formedness +
  uniqueness, known lifecycle statuses, charter-presence warning). Resolving a
  record's `supersedes_id` to a sibling record isn't possible from the
  token-scoped API today — the record JSON exposes `supersedes_id` as a UUID but
  no record's own UUID — so deeper cross-record integrity is deferred to Phase 6
  (and will likely need the API to serialize the supersede link as a slug).
- **Cross-compiled release binaries** are not yet produced here; the release
  profile is configured (`strip`, `lto`) and CI packaging folds in with Phase 6
  (Rust CI + the API surface into the quality gate).

### Phase 5 — Agent skill ✅ Complete

`skills/alloy/` (SKILL.md + `references/` + `workflows/`) teaching the six-field
model, lifecycle, key scheme, and charter; `alloy init [--global]` installs it
via `include_str!`, version-stamped.

**Delivered** (trunk-based on `main`; `cargo fmt --check`, `cargo clippy
--all-targets -- -D warnings`, and `cargo test` all green; `init` smoke-tested
end-to-end — create / up-to-date / downgrade-skip / `--force`):

- `f34333f` — the `alloy` agent skill under **`cli/skills/alloy/`** (co-located
  with the embedding crate, mirroring et's `apps/cli/skills/`): `SKILL.md` plus
  `references/cli-reference.md`, `references/intent-model.md`,
  `workflows/getting-started.md`, and `workflows/capturing-intent.md`. They
  teach the six-field record (capability/threat/expectation/strategy/evidence/
  tradeoff), the seven-state lifecycle and legal transitions, the
  `<project_key>.intent.<slug>` key scheme (slug `^[a-z0-9_-]+$`, immutable), and
  the five-field charter — all framed around the `alloy` CLI.
- `alloy init [--global] [--force]` installs/updates those files into
  `.claude/skills/alloy/` (or `~/.claude/skills/alloy/`). Files are embedded via
  `include_str!` and version-stamped (`alloy_version` in frontmatter); a re-run
  reports created/updated/up-to-date and refuses to overwrite a **newer**
  installed skill unless `--force`. The stamp/strip/parse, semver compare, and
  per-file action planning are a pure core with unit tests; the filesystem walk
  is the thin shell. `init` needs no `.alloy_env`, so the binary dispatches it
  before building the HTTP gateway.

**Deviation:** skill source lives at **`cli/skills/alloy/`** (not repo-root
`skills/alloy/` as the gap list sketched), keeping `include_str!` paths local to
the crate and matching the reference model's `apps/cli/skills/` layout. The
installed copy still lands in `.claude/skills/alloy/`.

### Phase 6 — Parity polish ✅ Complete

`validate` referential integrity, `docs --agents` content, Rust CI + API
surface folded into the quality gate.

**Delivered** (trunk-based on `main`; full Elixir `mix quality` gate green and
the Rust gate — `cargo fmt --check`, `cargo clippy --all-targets -- -D
warnings`, `cargo test` — green):

- `a8463c2` — closed the Phase 4 `validate` deferral. The record JSON now
  serializes a resolved **`supersedes_slug`** (the project-local slug of the
  record a given record supersedes) alongside the opaque `supersedes_id`; the
  list endpoint resolves it for free from the records it already returns, and
  single-record endpoints resolve the one link via `Alloy.Intent.slug_lookup/2`.
  `alloy validate` now checks supersede-link integrity (unresolved link →
  error; predecessor not itself `superseded` → warning) and warns on records
  left `hypothesized`; `intent show` surfaces lineage; `docs --agents` names the
  six fields and the key scheme.
- `478ec08` — Rust CLI quality gate folded into `ci.yml` (a `cli` job running
  fmt-check, clippy `-D warnings`, and tests, cached via `Swatinem/rust-cache`)
  on every push/PR to `main`, alongside the Elixir gate and the docs
  link-check.
- **Release-binary packaging** — `.github/workflows/release.yml` is
  tag-triggered (`v*`): a `verify` job asserts the tag matches
  `cli/Cargo.toml` (so the shipped `--version` is truthful), then a
  per-platform `build` matrix cross-compiles the `alloy` CLI on native-arch
  runners — `aarch64-apple-darwin` (macos-latest), `x86_64-apple-darwin`
  (macos-13), `x86_64-unknown-linux-gnu` (ubuntu-latest),
  `x86_64-pc-windows-msvc` (windows-latest) — and a `release` job attaches the
  four binaries plus a generated `SHA256SUMS.txt` to a GitHub Release. The
  earlier Phase 4 deviation ("release profile configured but binaries not
  produced") is now resolved.

- **S3 mirror + Homebrew distribution** — the `release` job packages the Unix
  binaries as `.tar.gz`, attaches them (with the Windows `.exe` and
  `SHA256SUMS.txt`) to the GitHub Release, mirrors the same bytes to
  `s3://alloy-releases/v<version>/` and `.../latest/`, and exports the tarball
  SHA-256s as job outputs. An `update-homebrew` job then writes `Formula/alloy.rb`
  into the shared **`svetzal/homebrew-tap`** (the same tap et/foundry/hopper use)
  pointing at the S3 tarball URLs, so `brew install svetzal/tap/alloy` works.
  Secrets: `HOMEBREW_TAP_TOKEN` (push to the tap) and `AWS_ACCESS_KEY_ID` /
  `AWS_SECRET_ACCESS_KEY` (an IAM user with `s3:PutObject` on the bucket). The
  tap update is skipped for pre-release tags (those containing `-`). The SHAs are
  computed from the exact tarball files the job uploads, so the formula's
  checksum always matches the S3 asset. Bucket/region (`alloy-releases` /
  `ca-central-1`) live in the workflow's top-level `env`.

This fully mirrors the et release model (cross-compiled binaries → GitHub
Release + S3 mirror → Homebrew tap formula) and closes the parity baseline.

## Settled defaults (override if needed)

- `/api/v1` versioning from the start.
- Per-project (not per-user) API tokens.
- Entity keys immutable after creation.
- snake_case slugs.
- `.alloy_env` filename, mirroring `.et_env`.

## Out of scope for this baseline

- Foundry integration and the `.alloy/` file projection (separate, later).
- Elicitation interviews, codebase archaeology, formation-brief generation,
  prompt packs, and trace feedback — these are downstream MVP features that
  build on this baseline.
