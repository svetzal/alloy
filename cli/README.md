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

## Commands

```bash
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
