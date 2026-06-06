---
title: Integration Architecture
summary: How Alloy's semantic product connects to Foundry's typed automation runtime through a stable artifact boundary.
layer: section
parent: index
tags: [integration, architecture, boundary]
---

# Integration Architecture

Alloy is a user-facing engineering-intent administration system, implemented as a Phoenix/LiveView application backed by PostgreSQL. It is a living model that humans can inspect, refine, and keep current through a responsive web interface.

Foundry is different. Foundry is a Rust-based system-level execution engine for engineering automation. It runs as `foundryd`, is controlled by the `foundry` CLI over gRPC, and is built around immutable events, composable task blocks, throttle, gate execution, and traces.

The split is healthy. Alloy should own meaning. Foundry should own execution.

## The challenge

The integration challenge is to connect a fast-evolving semantic product to a strongly typed automation runtime without collapsing them into one system. Alloy must not become a second workflow orchestrator. Foundry must not be forced to understand Alloy's full engineering-intent ontology.

## The stable seam

The stable seam is a small family of compiled [[runtime-artifacts]]:

- **Formation Briefs**: immutable intent packages for a specific run or reusable class of runs.
- **Prompt Packs**: phase-specific agent instructions compiled from product, design, and engineering intent.
- **Gate Overlays**: proposed or generated gate definitions that express required evidence.
- **Evidence Plans**: explicit statements of what would prove that the relevant capabilities were preserved.
- **Foundry Execution Requests**: narrow, versioned requests that tell Foundry which entry event, payload, throttle, project, and artifact references to use.
- **Foundry Run Results**: versioned summaries, trace references, gate outcomes, evidence observations, and feedback for Alloy.

Alloy's job is to compile intent into these artifacts. Foundry's job is to execute events and task blocks using those artifacts where appropriate, then report traces and evidence back. The feedback loop lets Alloy update intent satisfaction, detect drift, expose contradictions, and ask better questions next time.

## The guiding principle

> Alloy owns meaning. Foundry owns execution. Formation Briefs are the boundary.

This is a decision about responsibility boundaries, not about hosting. The architecture deliberately does **not** require a single deployment topology: Alloy may begin as a local or self-hosted Phoenix app and later become hosted, multi-tenant, or enterprise self-hosted; Foundry may run locally beside repositories, on a workstation, in a controlled runner environment, or in a project automation host. See [[ownership-boundary]] for how this seam is policed in practice.

## In this section

- [[architectural-decision]] — Alloy as a Phoenix product, Foundry as a Rust engine, joined by a versioned artifact-and-request boundary.
- [[boundary-principles]] — Alloy owns meaning, Foundry owns execution, and the rules against semantic and orchestration leakage.
- [[system-roles]] — what Alloy, Foundry, Epilogue Tracker, the design intent system, and the runner each own.
- [[runtime-topology]] — the recommended runner-initiated topology and its local, hosted, and enterprise variants.
- [[integration-modes]] — the phased path from manual file projection to native Foundry integration.
- [[idempotency-and-correlation]] — how runs stay safely repeatable and traceable.
- [[security-and-authority]] — where authority and credentials live.
- [[failure-handling]] — how failures are bounded and surfaced.
- [[observability-and-audit]] — traces, evidence, and audit across the seam.
- [[versioning-and-compatibility]] — how artifacts and requests evolve without breaking.

## Related

- [[ownership-boundary]] — the discipline that keeps the two systems from collapsing.
- [[end-to-end-flows]] — how the artifacts move through a complete run.
- [[phased-integration-plan]] — the rollout sequence that maps onto the integration modes.

*Source: Integration Architecture §1 (Executive Summary) and §3.3 (Non-decision).*
