---
title: API
summary: The Alloy HTTP API surfaces for product/intent workflows and for runner, run-request, and Foundry integration.
layer: leaf
parent: interfaces
tags: [api, http, runners, foundry]
---

# API

Alloy exposes HTTP APIs both for product and intent workflows and for runners
and Foundry integrations. The surfaces below are grouped by purpose.

## Product / intent endpoints

These candidate endpoints cover intent records, discoveries, hypotheses,
formation briefs, drift, and trace ingestion:

- `GET /projects/{id}/intent-records`
- `POST /projects/{id}/intent-records`
- `POST /projects/{id}/discoveries`
- `GET /projects/{id}/hypotheses`
- `POST /hypotheses/{id}/accept`
- `POST /formation-briefs`
- `GET /formation-briefs/{id}`
- `POST /formation-briefs/{id}/compile-prompts`
- `POST /foundry/traces/{trace_id}/ingest`
- `GET /projects/{id}/drift`

## Runner / run-request / Foundry endpoints

Alloy should expose APIs for runners and Foundry integrations. These candidate
endpoints cover Foundry capabilities, formation briefs, the run-request
lifecycle that runners poll and update, and Foundry run observations:

```text
GET  /api/projects/:id/foundry-capabilities
POST /api/projects/:id/foundry-capabilities

POST /api/projects/:id/formation-briefs
GET  /api/formation-briefs/:id
GET  /api/formation-briefs/:id/compiled

POST /api/projects/:id/run-requests
GET  /api/runners/:runner_id/run-requests/next
POST /api/run-requests/:id/accepted
POST /api/run-requests/:id/started
POST /api/run-requests/:id/events
POST /api/run-requests/:id/completed
POST /api/run-requests/:id/failed

POST /api/foundry-runs/:id/trace-summary
POST /api/foundry-runs/:id/evidence-observations
```

The run-request endpoints carry a [[foundry-execution-request]] to runners and
collect a [[foundry-run-result]] back. How runners connect to these surfaces
depends on the chosen [[integration-modes]] and the deployed
[[runtime-topology]].

Up: [[interfaces]] · Related: [[cli]]

*Source: Product Brief §21 (API and CLI Seed); Integration Architecture §11.1 (Alloy API surface).*
