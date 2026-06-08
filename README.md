# Alloy

Alloy is a Phoenix/LiveView administration product for capturing and
refining **engineering intent** — the capabilities a team must preserve
as software changes. It sits above the Rust "Foundry" execution engine
and beside Epilogue Tracker, integrating with Foundry through versioned
artifacts.

The authoritative product specification lives in [`docs/`](docs/index.md)
and is published at <https://vetzal.com/alloy/>. For how to develop in
this repo — stack, commands, the quality gate, and conventions — see
[`AGENTS.md`](AGENTS.md).

## Layout

This is a monorepo with two apps and a shared docs site:

- [`apps/web/`](apps/web/) — the Phoenix/LiveView app and PostgreSQL data
  layer ([`apps/web/AGENTS.md`](apps/web/AGENTS.md)).
- [`apps/cli/`](apps/cli/) — the `alloy` thin-client Rust CLI
  ([`apps/cli/AGENTS.md`](apps/cli/AGENTS.md)).
- [`docs/`](docs/index.md) — the product spec and the VitePress site.

## Quick start

```bash
cd apps/web
mix setup          # deps + database + assets
mix phx.server     # http://localhost:4000
```

Database credentials default to the local OS user (trust-auth Postgres)
and are overridable via `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_NAME`.

## Quality gate

```bash
cd apps/web
mix quality        # format, compile (warnings as errors), credo, sobelow, test
mix dialyzer       # type analysis
mix deps.audit     # dependency vulnerability scan
```

The Rust CLI has its own gate (`cargo fmt --check`, `cargo clippy`,
`cargo test`) — run from `apps/cli/`. See [`AGENTS.md`](AGENTS.md) for the
full gates and engineering philosophy.

## Learn more

- Phoenix: https://hexdocs.pm/phoenix/overview.html
- Phoenix LiveView: https://hexdocs.pm/phoenix_live_view
- Ecto: https://hexdocs.pm/ecto

## License

Proprietary — © 2026 Mojility Inc. All rights reserved. See [`LICENSE`](LICENSE).
The source is public for visibility; it is not open source. Licensing
inquiries: licensing@mojility.ca
