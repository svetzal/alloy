---
title: MVP Proposal
summary: A projection-only MVP that turns engineering intent into better Foundry runs without rewriting Foundry.
layer: leaf
parent: delivery
tags: [mvp, projection, scope, success-criteria]
---

# MVP Proposal

## MVP objective

Prove that Alloy can turn engineering intent into better Foundry runs without
rewriting Foundry.

## MVP scope

### 0. Phoenix/LiveView administration system

Treat Alloy as a user-facing administration product from the beginning. The MVP
should have a small Phoenix/LiveView surface for projects, engineering intent
records, hypothesis review, [[formation-brief|Formation Brief]] review, and
Foundry run feedback. This does not mean the integration must be deep in the
MVP; it means the human-facing intent model should not be hidden in CLI-only
files.

### 1. Engineering intent records

- Create/edit/list records.
- Fields: capability, threat, expectation, strategy, evidence, tradeoff, status,
  scope, source.
- Store in PostgreSQL or local SQLite/Postgres-compatible model for early
  development.
- Export markdown/YAML projection.

### 2. Assistant-led elicitation

Support three interview modes:

- Why is this here?
- What would make you reject a PR?
- What scar are you avoiding?

### 3. Lightweight codebase archaeology

Start with static repository inspection (see [[codebase-archaeology]]):

- Directory/module structure.
- Test structure.
- Imports/dependencies.
- Existing gates.
- `CHARTER.md`, README, AGENTS-like files.

Output hypotheses only.

### 4. Formation brief generation

Given:

- One product objective or plain-language mission.
- Selected engineering intent records.
- Optional Epilogue interaction reference.

Produce:

- [[formation-brief|Formation brief]] YAML.
- [[prompt-pack|Prompt pack]] text files.
- Suggested Foundry payload.

### 5. Foundry integration by projection

Do not initially require Foundry code changes. Generate a local package Foundry
can consume through existing prompt or strategic prompt mechanisms — the
projection mode described in [[integration-modes]].

Example output directory:

```text
.alloy/
  briefs/
    checkout-payment.yaml
  prompts/
    assessment.md
    triage.md
    planning.md
    execution.md
    retry.md
    summary.md
  gates/
    overlay.hone-gates.json
  projections/
    CHARTER.generated.md
```

### 6. Trace feedback import

Start with manual trace ingestion:

```bash
alloy trace ingest <event-id>
```

Summarize:

- Which gates passed.
- Whether retry happened.
- Which intent records were in scope.
- Which evidence remains unknown.

## MVP success criteria

The MVP is successful if:

1. A developer can create useful engineering intent records in under 30 minutes.
2. Alloy can discover at least three plausible intent hypotheses from a real
   codebase.
3. A human can accept/edit/reject those hypotheses quickly.
4. Alloy can compile selected intent into a Foundry-usable prompt package.
5. A Foundry run using Alloy context produces more relevant assessment and
   planning than a generic `strategic_prompt`.
6. Alloy can ingest a Foundry trace and report intent satisfaction or gaps.

Up: [[delivery]]

*Source: Product Brief §23 (MVP Proposal).*
