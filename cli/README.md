# `alloy` — Alloy CLI

A thin-client CLI for the Alloy engineering-intent backend. It holds no local
data: every command talks to the `/api/v1` JSON API over HTTP, authenticated by
a per-project bearer token.

## Configuration

Create a `.alloy_env` file in your project root (it is gitignored — it holds a
secret):

```bash
ALLOY_API_HOST=https://alloy.example.com
ALLOY_API_TOKEN=alloy_your-token-here
```

Mint a token in the Alloy web console: **Projects → a project → Generate
token**. The file is read from the current working directory only (no
directory-tree walk).

`alloy init` needs no `.alloy_env` — it only installs the embedded agent skill
files (version-stamped) into `.claude/skills/alloy/`, refusing to overwrite a
newer installed skill unless `--force` is given. The skill teaches agents the
six-field intent model and this CLI; run it again after upgrading the binary.

## Commands

```bash
alloy init [--global] [--force]          # install the agent skill into .claude/skills/alloy/

alloy project show                       # show the token-scoped project
alloy project set --name "New Name"      # rename it

alloy charter show                       # show the product charter
alloy charter set --mission "..." \      # set one or more fields (others kept)
                  --target-audience "..." \
                  --problem-space "..." \
                  --differentiators "..." \
                  --out-of-scope "..."

alloy intent list                        # list intent records
alloy intent show <slug>                 # show one record
alloy intent create --title "..." \      # slug derived from title when omitted
                    [--slug ...] [--capability ...] [--threat ...] \
                    [--expectation ...] [--strategy ...] \
                    [--evidence-summary ...] [--tradeoff ...] \
                    [--status ...] [--confidence 0.0-1.0]
alloy intent update <slug> [--field ...] # update fields
alloy intent remove <slug>               # delete a record

alloy intent accept <slug>               # lifecycle transitions
alloy intent activate <slug>
alloy intent deprecate <slug>
alloy intent contradict <slug>
alloy intent supersede <slug> [--by <replacement-slug>]

alloy validate                           # referential-integrity checks
alloy docs --agents [--output FILE]      # agent-facing project docs
```

Add `--json` to any command for a machine-readable `{success, data, error}`
envelope. Exit code is `0` on success, `1` on error (and `1` from `validate`
when it finds any error-level issue).

## Development

```bash
cargo build              # debug build
cargo test               # unit tests (command logic over an in-memory fake API)
cargo clippy --all-targets -- -D warnings
cargo fmt --check
cargo build --release    # optimized, stripped binary at target/release/alloy
```

The crate follows the repo's functional-core / imperative-shell split: command
logic is written against the `Api` gateway trait (in `src/api.rs`) and tested
with an in-memory fake; the real `reqwest` implementation is the thin
`HttpApi` in `src/http.rs`.

## Releases

Pushing a `vX.Y.Z` tag triggers `.github/workflows/release.yml`, which verifies
the tag matches the crate version, cross-compiles per-platform binaries
(`alloy-darwin-arm64`, `alloy-darwin-x64`, `alloy-linux-x64`,
`alloy-windows-x64.exe`), and attaches them — with a `SHA256SUMS.txt` — to a
GitHub Release. To cut a release: bump `version` in `Cargo.toml`, commit, then
tag (`git tag v0.2.0 && git push origin v0.2.0`).
