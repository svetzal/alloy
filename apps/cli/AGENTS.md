# AGENTS.md — Alloy CLI (`apps/cli/`)

The `alloy` command: a **thin-client Rust CLI** for the Alloy
engineering-intent backend. It holds no local data — every command talks
to the `/api/v1` JSON API over HTTP, authenticated by a per-project
bearer token (`.alloy_env`). Run every `cargo` command from this
directory (`apps/cli/`).

**Suggested subagent:** `rust-craftsperson`.

See `README.md` (in this directory) for the full command reference,
configuration (`.alloy_env`), installation, and the release process.

## Architecture

The crate follows the repo's **functional-core / imperative-shell**
split:

- Command logic is written against the `Api` gateway trait
  (`src/api.rs`) and tested with an in-memory fake.
- The real `reqwest` implementation is the thin `HttpApi` in
  `src/http.rs` — no logic, so it is not unit-tested directly.
- Embedded agent-skill files live in `skills/` and are `include_str!`'d
  into the binary; `alloy init` installs them into a project's
  `.claude/skills/alloy/`.

## Quality gate (the standard for "done")

All run from `apps/cli/`; all must be green before pushing:

```bash
cargo fmt --check
cargo clippy --all-targets -- -D warnings
cargo test
cargo build --release      # verify the optimized binary builds
```

## Versioning & releases

- **`Cargo.toml` is the single source of truth** for the version
  `alloy --version` reports. Always `cargo build` after bumping it so
  `Cargo.lock` updates in the same commit.
- A pushed `vX.Y.Z` tag triggers `.github/workflows/release.yml`, which
  verifies the tag matches `apps/cli/Cargo.toml`, cross-compiles the
  per-platform binaries, publishes a GitHub Release, mirrors assets to
  `s3://alloy-releases/`, and updates the Homebrew formula. See
  `README.md` → Releases for the full pipeline and required secrets.

See the repo-root `AGENTS.md` for cross-cutting concerns and `docs/` for
the product spec.
