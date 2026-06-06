---
title: CLI
summary: The Alloy developer command-line tool for project setup, intent discovery, briefs, Foundry runs, drift, and trace feedback.
layer: leaf
parent: interfaces
tags: [cli, workflows, foundry]
---

# CLI

The Alloy CLI supports developer workflows and Foundry integration. The
examples below cover the core commands.

## Initialize Alloy for a project

```bash
alloy init my-project
```

Creates local config and links the project to an Alloy workspace.

## Discover intent from codebase

```bash
alloy discover my-project --path .
```

Runs [[codebase-archaeology]] and produces hypotheses.

## Review hypotheses

```bash
alloy review hypotheses my-project
```

Presents accept/edit/reject choices over the generated hypotheses. See
[[hypothesis-format]] for the structure of a hypothesis.

## Ask an elicitation question

```bash
alloy ask my-project --mode scars
```

Starts an assistant-led interview.

## Create a formation brief

```bash
alloy brief create my-project \
  --epilogue-interaction et.interaction.checkout.submit-payment \
  --intent alloy.intent.gateway.payment-provider \
  --intent alloy.intent.functional-core.checkout-policy
```

Assembles a [[formation-brief]] from the named interaction and intent records.

## Run through Foundry

```bash
alloy foundry run alloy.brief.checkout-payment.2026-06-06 \
  --dry-run-first
```

This could compile local artifacts and emit the appropriate Foundry event.

## Export repo-local projection

```bash
alloy export charter my-project --output CHARTER.md
alloy export agents my-project --output AGENTS.md
```

These are projections, not the canonical store.

## Assess drift

```bash
alloy drift my-project
```

Compares active intent records against code observations and gate evidence.
See [[drift-detection]] for how drift is assessed.

## Import Foundry trace feedback

```bash
alloy trace ingest my-project <event-id>
```

Looks up the Foundry trace and updates run feedback. See [[trace-feedback]] for
how ingested traces flow back into Alloy.

Up: [[interfaces]] · Related: [[api]]

*Source: Product Brief §21 (API and CLI Seed).*
