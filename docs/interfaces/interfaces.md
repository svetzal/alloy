---
title: Interfaces
summary: Alloy exposes a developer CLI and an HTTP API for working with intent, briefs, runs, and integrations.
layer: section
parent: index
tags: [interfaces, cli, api]
---

# Interfaces

Alloy provides two surfaces for interacting with the system: a developer-facing
command-line tool and an HTTP API.

- The **[[cli|CLI]]** supports developer workflows and Foundry integration —
  initializing projects, discovering intent, reviewing hypotheses, creating
  formation briefs, running through Foundry, and ingesting trace feedback.
- The **[[api|HTTP API]]** supports runners and integrations — exposing intent
  records, hypotheses, formation briefs, run requests, and Foundry run
  observations.

Both surfaces operate over the same canonical store; the CLI's repo-local
exports are projections rather than the source of truth.

Continue to:

- [[cli]] — the developer command-line tool
- [[api]] — the HTTP API surfaces

Up: [[index]]

*Source: Product Brief §21 (API and CLI Seed).*
