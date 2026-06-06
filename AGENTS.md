# AGENTS.md — Working in the Alloy repository

Alloy is a Phoenix/LiveView administration product for capturing and
refining **engineering intent**. It sits above the Rust "Foundry"
execution engine and integrates with it through versioned artifacts.
This repo is the Phoenix/LiveView app and its PostgreSQL data layer.

> **The product spec lives in `docs/`.** It is the authoritative source
> of truth for the domain. Start at `docs/index.md`, then
> `docs/delivery/mvp.md`, `docs/data-model/core-entities.md`, and
> `docs/integration/architectural-decision.md`. **Do not modify `docs/`**
> as part of implementation work — treat it as read-only spec. `docs/` is
> also the source for the published documentation site (see
> [Documentation site](#documentation-site)).

The Foundry integration itself is **out of scope** for current work
unless a task says otherwise.

## Tech stack

- **Elixir** ~> 1.15 (developed on 1.19.5) / **Erlang/OTP 28**.
- **Phoenix 1.8** + **LiveView 1.1**, **Bandit** server.
- **Ecto 3 + PostgreSQL** (`postgrex`). Primary keys are **`binary_id`
  (UUID)** — the data model uses UUID-ish ids throughout.
- **Tailwind** + **daisyUI** + **esbuild** for assets.
- **Req** for HTTP (never `:httpoison`/`:tesla`/`:httpc`).

## Common commands

```bash
mix setup            # deps, db create+migrate+seed, assets
mix phx.server       # run the app at http://localhost:4000
iex -S mix phx.server

mix test             # run the suite (auto creates/migrates test db)
mix test path/to/test.exs:42
mix test --cover     # coverage (threshold ratchets up over time)

mix quality          # FULL GATE: format check, compile (warnings as
                     # errors), credo --strict, sobelow, test
mix dialyzer         # type analysis (slow; PLT cached in priv/plts)
mix deps.audit       # dependency vulnerability scan
mix hex.audit        # retired-package check
mix docs             # generate ex_doc
```

### Database

Dev/test DB credentials are environment-overridable and default to the
local OS user for trust-auth Postgres:

- `DB_USER` (default: `$USER`, else `postgres`)
- `DB_PASSWORD` (default: empty)
- `DB_HOST` (default: `localhost`)
- `DB_NAME` (default: `alloy_dev`)

Production is driven entirely by `config/runtime.exs` (`DATABASE_URL`).

If the database has not been created yet:

```bash
mix ecto.create && mix ecto.migrate
```

## Quality gate (the standard for "done")

Work is not done until **all** of these are green:

| Gate | Command | Notes |
|------|---------|-------|
| Format | `mix format --check-formatted` | |
| Compile | `mix compile --warnings-as-errors` | warnings are errors |
| Lint | `mix credo --strict` | **zero** issues |
| Security (code) | `mix sobelow --config` | fails on any low+ finding |
| Security (deps) | `mix deps.audit` | known-vuln scan |
| Tests | `mix test` | all pass |
| Coverage | `mix test --cover` | above configured threshold |
| Types | `mix dialyzer` | zero errors |

`mix quality` runs the fast subset (everything except `dialyzer` and
`deps.audit`, which are run separately because they are slow or
network-dependent). Run `dialyzer` and `deps.audit` before pushing.

### Acknowledged scaffold-level exceptions

- **Sobelow `Config.CSP` / `Config.HTTPS`** are ignored in
  `.sobelow-conf`. `Config.HTTPS`: Alloy runs behind a reverse proxy
  that terminates TLS, so the app serves plain HTTP and does not manage
  certs/HSTS — a settled decision, not a follow-up. `Config.CSP`: a
  Content-Security-Policy is authored once the UI's script needs are
  known (revisit during UI hardening).
- **Coverage threshold** is low at bootstrap (mostly generated
  boilerplate). RAISE it as domain code lands; the functional core
  should sit well above 90%.

## Documentation site

The `docs/` wiki is published as a **VitePress** site to **GitHub Pages**
at `https://svetzal.github.io/alloy/`. The Bun toolchain at the repo root
manages it (mirroring the epilogue-tracker docs setup).

```bash
bun install          # one-time: install VitePress + mermaid
bun run docs:dev     # local preview at http://localhost:5173/alloy/
bun run docs:build   # production build (also the CI link-check)
bun run docs:preview # serve the built site
```

Conventions for `docs/` content:

- **Wikilinks.** Pages link with `[[slug]]` or `[[slug|Display text]]`,
  where `slug` is a **globally-unique filename** (no extension, no path).
  A custom markdown-it plugin in `docs/.vitepress/config.ts` resolves
  these at build time; un-piped links render the target's frontmatter
  `title`. Wikilinks inside backticks stay literal.
- **Frontmatter.** Each page has `title`, `summary`, `layer`
  (`home` | `section` | `leaf`), `parent`, and `tags`. The **sidebar is
  generated** from the folder structure and the one `layer: section`
  overview per folder — no hand-maintained nav lists.
- **Dead links fail the build** (`ignoreDeadLinks: false`), so a broken
  `[[wikilink]]` breaks CI. Adding a page is enough for it to appear.

`docs.yml` builds and deploys on push to `main` (paths `docs/**`); `ci.yml`
also builds the site on PRs as a link-check. ExDoc (`mix docs`) remains the
generator for **code/API** reference — separate concern from this prose site.

## CI

`.github/workflows/ci.yml` runs the full Elixir quality gate (with a
Postgres service and cached deps/PLT), the Rust CLI gate (`cargo fmt --check`,
`cargo clippy --all-targets -- -D warnings`, `cargo test` in `cli/`), and the
docs link-check on every push and PR to `main`. `.github/workflows/docs.yml`
deploys the docs site to GitHub Pages. `.github/workflows/release.yml` is
tag-triggered (`v*`): it verifies the tag matches `cli/Cargo.toml`, then
cross-compiles the `alloy` CLI for macOS (arm64/x64), Linux x64, and Windows
x64, attaches the binaries plus a `SHA256SUMS.txt` to a GitHub Release, and
updates `Formula/alloy.rb` in the shared `svetzal/homebrew-tap` (needs a
`HOMEBREW_TAP_TOKEN` secret; skipped for pre-release tags).

## How we build (engineering philosophy)

- **Functional core, imperative shell.** Pure business logic lives in
  `lib/alloy/` contexts with no side effects. I/O — DB, HTTP, the
  filesystem, the eventual Foundry boundary — is pushed to thin
  **gateway** modules behind behaviours. Web (`lib/alloy_web/`) depends
  on core, never the reverse.
- **Gateways, not mocked internals.** Only mock gateway behaviours (via
  **Mox**); never mock library internals. If you need to fake a
  third-party library, wrap it in a gateway first. Don't write tests for
  thin gateways with no logic — move any logic into the core and test it
  there.
- **Tests are the spec.** Prefer writing the failing test first. Test
  behaviour, not implementation. Use `start_supervised!/1`; avoid
  `Process.sleep/1`.
- **Contexts own queries.** Never put Ecto queries in LiveViews; always
  use changesets for writes; always preload associations used in
  templates.
- **Phoenix conventions.** Follow `usage-rules.md` (the Phoenix/Elixir
  framework guidance shipped with the installer) for LiveView, HEEx,
  forms, streams, auth scopes, and UI/dark-mode rules.

## Version control (trunk-based)

- Work happens on **`main`**. No long-lived feature branches, no PRs as
  gates. Integration is the commit.
- Commit scoped, working changes at logical stopping points. Stage
  **specific paths** (`git add <files>`) — never `git add -A`/`git add .`.
- `docs/` **is** versioned (it is the spec and the published site); just
  don't bundle unrelated changes into a docs commit, and don't rewrite
  spec content as a side effect of implementation work.
- End every commit message with:

  ```text
  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
  ```

## Repo layout

```text
lib/alloy/          # functional core: contexts, schemas, gateways (no web deps)
lib/alloy_web/      # web shell: LiveViews, controllers, components, router
priv/repo/          # migrations + seeds
test/               # ExUnit; test/support has DataCase / ConnCase
docs/               # PRODUCT SPEC (read-only) + VitePress site source
docs/.vitepress/    # VitePress config: wikilink plugin + generated sidebar
.github/workflows/  # ci.yml (Elixir gate + docs check), docs.yml (Pages deploy)
package.json        # Bun-managed VitePress toolchain (docs only)
usage-rules.md      # Phoenix/Elixir framework guidance
```
