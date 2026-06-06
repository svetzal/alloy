---
title: Architectural Decision
summary: Alloy is a Phoenix/LiveView product, Foundry is a Rust engine, and they integrate through a versioned artifact-and-request boundary.
layer: leaf
parent: integration-architecture
tags: [decision, boundary, integration]
---

# Architectural Decision

Alloy should be built as a Phoenix/LiveView product, not as another Rust subsystem inside Foundry.

Foundry should remain a Rust execution engine.

The integration should use a versioned artifact-and-request boundary rather than direct internal coupling.

## Decision statement

Alloy will operate as a user-facing administration system for engineering intent. It will provide the UI, data model, assistant interactions, review workflows, and collaboration mechanisms needed to capture and refine developer intent.

Foundry will continue to operate as a Rust daemon and CLI-controlled execution runtime. It will execute engineering automation through events, task blocks, gates, throttle, and traces.

Alloy will feed Foundry by producing immutable runtime artifacts and narrow execution requests. Foundry will report traces and evidence back to Alloy. See [[alloy-and-foundry]] for the relationship in detail.

## Why this split fits the forces

Alloy needs fast product iteration. Its primary challenges are human-facing: elicitation, review, navigation, explanation, collaboration, dashboarding, and model refinement. Phoenix/LiveView is well suited to that because it makes stateful, responsive, server-rendered administration interfaces relatively cheap to build.

Foundry needs runtime safety and execution discipline. Its primary challenges are system-facing: event handling, process execution, gate orchestration, retry, side-effect control, traceability, and safe concurrency. Rust is well suited to that because Foundry benefits from strong types, explicit side-effect boundaries, and compiler-enforced invariants.

Trying to make Alloy a Rust UI or trying to make Foundry a Phoenix workflow engine would distort both products.

## Non-decision

This document does not require a single deployment topology. Alloy may begin as a local or self-hosted Phoenix app. It may later become hosted, multi-tenant, or enterprise self-hosted. Foundry may run locally beside repositories, on a workstation, in a controlled runner environment, or in a project automation host.

The decision is about responsibility boundaries, not hosting. Those boundaries are spelled out in [[boundary-principles]].

## Related

- [[integration-architecture]] — section overview.
- [[boundary-principles]] — the rules that keep the boundary clean.
- [[alloy-and-foundry]] — the two-system relationship.

*Source: Integration Architecture §3 (Architectural Decision).*
