# AGENTS.md — Working in the Alloy repository

Alloy is a product for capturing and refining **engineering intent**. It
sits above the Rust "Foundry" execution engine and integrates with it
through versioned artifacts. This is a **monorepo** with two apps and a
shared documentation site.

> **The product spec lives in `docs/`.** It is the authoritative source
> of truth for the domain. Start at `docs/index.md`, then
> `docs/delivery/mvp.md`, `docs/data-model/core-entities.md`, and
> `docs/integration/architectural-decision.md`. **Do not modify `docs/`**
> as part of implementation work — treat it as read-only spec. `docs/` is
> also the source for the published documentation site (see
> [Documentation site](#documentation-site)).

The Foundry integration itself is **out of scope** for current work
unless a task says otherwise.

## Per-app agent guidance

Each app has its own AGENTS.md with technology-specific guidance and its
own quality gate. **Load the relevant file based on your working
context:**

| Working in   | Agent file            | Suggested subagent             |
|--------------|-----------------------|--------------------------------|
| `apps/web/`  | `apps/web/AGENTS.md`  | `elixir-phoenix-craftsperson`  |
| `apps/cli/`  | `apps/cli/AGENTS.md`  | `rust-craftsperson`            |

- **`apps/web/`** — the Phoenix 1.8 / LiveView 1.1 application and its
  PostgreSQL data layer. This is where the domain model and UI live.
- **`apps/cli/`** — the `alloy` thin-client Rust CLI. It ships in
  releases and via Homebrew, and talks to the web app's `/api/v1` JSON
  API. It holds no local data.

## Repo layout

```text
alloy/
├── apps/
│   ├── web/                # Phoenix/LiveView app (mix.exs here)
│   │   ├── lib/alloy/      # functional core: contexts, schemas, gateways
│   │   ├── lib/alloy_web/  # web shell: LiveViews, controllers, components
│   │   ├── priv/repo/      # migrations + seeds
│   │   ├── test/           # ExUnit; test/support has DataCase / ConnCase
│   │   ├── config/         # Elixir/Phoenix config
│   │   ├── assets/         # Tailwind + esbuild sources
│   │   ├── usage-rules.md  # Phoenix/Elixir framework guidance
│   │   └── AGENTS.md       # Elixir/Phoenix gate + guidance
│   └── cli/                # Rust CLI (`alloy` command; Cargo.toml here)
│       ├── src/            # command logic (Api gateway trait) + HttpApi
│       ├── skills/         # embedded agent-skill files (include_str!'d)
│       └── AGENTS.md       # Rust gate + guidance
├── docs/                   # PRODUCT SPEC (read-only) + VitePress site source
│   └── .vitepress/         # VitePress config: wikilink plugin + generated sidebar
├── .github/workflows/      # ci.yml (per-app gates + docs check), docs.yml, release.yml
├── package.json            # Bun-managed VitePress toolchain (docs only)
└── AGENTS.md               # this file (shared concerns + routing table)
```

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
also builds the site on PRs as a link-check. ExDoc (`mix docs` in
`apps/web/`) remains the generator for **code/API** reference — separate
concern from this prose site.

## CI

`.github/workflows/ci.yml` runs three independent jobs on every push and
PR to `main`:

- **Elixir quality gate** (`working-directory: apps/web`) — the full
  `mix quality` gate against a Postgres service, with cached deps/PLT,
  plus `deps.audit`, `hex.audit`, and `dialyzer`.
- **Rust CLI quality gate** (`working-directory: apps/cli`) —
  `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`,
  `cargo test`.
- **Docs build (link check)** — `bun run docs:build` at the repo root.

`.github/workflows/docs.yml` deploys the docs site to GitHub Pages.
`.github/workflows/release.yml` is tag-triggered (`v*`): it verifies the
tag matches `apps/cli/Cargo.toml`, cross-compiles the `alloy` CLI for
macOS (arm64/x64), Linux x64, and Windows x64, attaches the binaries plus
a `SHA256SUMS.txt` to a GitHub Release, mirrors them to
`s3://alloy-releases/`, and updates `Formula/alloy.rb` in the shared
`svetzal/homebrew-tap` (needs `HOMEBREW_TAP_TOKEN` and `AWS_ACCESS_KEY_ID` /
`AWS_SECRET_ACCESS_KEY` secrets; the tap update is skipped for pre-release
tags).

## How we build (engineering philosophy)

Both apps share the same spine:

- **Functional core, imperative shell.** Pure business logic has no side
  effects; I/O — DB, HTTP, the filesystem, the eventual Foundry boundary
  — is pushed to thin **gateway** modules behind behaviours/traits.
- **Gateways, not mocked internals.** Only mock gateway boundaries; never
  mock library internals. Don't write tests for thin gateways with no
  logic — move any logic into the core and test it there.
- **Tests are the spec.** Prefer writing the failing test first. Test
  behaviour, not implementation.

Per-language specifics (commands, quality gates, conventions) live in each
app's `AGENTS.md`.

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
