---
title: System Roles
summary: What Alloy, Foundry, Epilogue Tracker, the design intent system, and the runner each are responsible for.
layer: leaf
parent: integration-architecture
tags: [roles, responsibilities, integration]
---

# System Roles

## Alloy

Alloy is the engineering-intent administration and compilation layer.

Alloy is responsible for:

- Capturing engineering intent records.
- Helping developers express tacit engineering judgement.
- Extracting intent hypotheses from existing codebases.
- Managing review and acceptance of intent records.
- Relating engineering intent to product intent from Epilogue Tracker.
- Relating engineering intent to future design intent systems.
- Compiling selected intent into Formation Briefs.
- Compiling phase-specific Prompt Packs.
- Generating Evidence Plans and Gate Overlays.
- Creating Foundry Execution Requests.
- Recording Foundry Run Results.
- Ingesting traces and evidence observations.
- Detecting intent drift.
- Maintaining repo-local projections where useful.

## Foundry

Foundry is the event-driven engineering execution substrate.

Foundry is responsible for:

- Receiving entry events.
- Routing events to task blocks.
- Applying throttle.
- Running observers and mutators.
- Resolving and running gates.
- Invoking agents from execution blocks.
- Retrying bounded failures.
- Producing traces.
- Returning run results.
- Preserving execution safety and auditability.

The Alloy/Foundry relationship is described in detail in [[alloy-and-foundry]].

## Epilogue Tracker

Epilogue Tracker remains the source of product intent.

Epilogue-owned model elements include:

- Actors.
- Actor goals.
- Interactions.
- Outcomes.
- Work connected to user outcomes.
- Missing or broken product-intent connections.

Alloy should not duplicate that model. It should reference it. See [[alloy-and-epilogue-tracker]].

## Design intent system

A future [[design-intent-system|design intent system]] should own experience intent.

Possible design-owned model elements include:

- Interaction design constraints.
- UI flows.
- Screens.
- Visual language.
- Affordances.
- Tone.
- Accessibility and usability expectations.
- Experience-level evidence.

Alloy should not duplicate design intent either. It should reference and combine it during Formation Brief compilation.

## Runner or bridge

A bridge component may be needed between Alloy and Foundry.

The bridge is responsible for:

- Running near the codebase and Foundry daemon.
- Pulling assigned Formation Briefs or Execution Requests from Alloy.
- Materializing briefs, prompt packs, and gate overlays locally.
- Calling `foundry` or `foundryd`.
- Streaming or posting traces and run results back to Alloy.
- Holding local credentials and repository access.

This bridge may start as a simple CLI adapter and evolve into a durable runner. Where it sits in the deployment picture is covered in [[runtime-topology]].

## Related

- [[integration-architecture]] — section overview.
- [[alloy-and-foundry]] — the two-system relationship.
- [[alloy-and-epilogue-tracker]] — product-intent reference.
- [[design-intent-system]] — experience-intent reference.
- [[runtime-topology]] — where these roles run.

*Source: Integration Architecture §5 (System Roles).*
