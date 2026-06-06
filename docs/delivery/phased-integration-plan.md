---
title: Phased Integration Plan
summary: How Alloy couples to the Foundry runtime over six phases, from product-local projection to a full learning loop.
layer: leaf
parent: delivery
tags: [integration, phases, foundry, planning]
---

# Phased Integration Plan

This plan governs how tightly Alloy couples to the Foundry runtime. It moves from
the loosest coupling — product-local projection, the same mode used by the
[[mvp]] — toward a full learning loop, and parallels the product [[roadmap]]. For
the coupling levels themselves, see [[integration-modes]].

## Phase 0: Product-local projection

Goal: prove that Alloy-generated context improves Foundry runs without requiring
Foundry changes.

Build:

- Phoenix/LiveView UI for intent records.
- [[formation-brief|Formation Brief]] generation.
- [[prompt-pack|Prompt Pack]] generation.
- Repo-local `.alloy/` projection.
- Manual Foundry invocation instructions.
- Manual trace import.

## Phase 1: CLI bridge

Goal: let Alloy create Foundry requests through a local bridge.

Build:

- Local bridge command.
- Runner registration.
- Project mapping.
- CLI invocation of Foundry.
- Run result posting.
- Basic idempotency.

## Phase 2: Native brief references

Goal: let Foundry blocks resolve Alloy artifacts intentionally.

Build:

- Foundry payload convention for `alloy.brief_id` and digest.
- Local artifact provider.
- Prompt Pack resolver.
- Gate Overlay resolver.
- Run result exporter.

## Phase 3: Trace streaming and evidence observations

Goal: make Alloy's UI reactive during Foundry runs.

Build:

- Runner heartbeat.
- Run event stream.
- Trace summary upload.
- Evidence observation ingestion.
- Intent satisfaction dashboard.

## Phase 4: Configurable formation composition

Goal: align Alloy with Foundry's extracted composition layer.

Build:

- Foundry capability manifest.
- Formation composition schema.
- Alloy formation designer.
- Compatibility checker.
- Contract tests.

## Phase 5: Learning loop

Goal: make traces improve the intent model. See [[trace-feedback]].

Build:

- Drift detection.
- Contradiction detection.
- Strategy effectiveness observations.
- Tradeoff observations.
- Assistant-generated follow-up questions.
- Intent record lifecycle automation.

Up: [[delivery]]

*Source: Integration Architecture §22 (Phased Implementation Plan).*
