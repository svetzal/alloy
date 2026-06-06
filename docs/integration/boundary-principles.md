---
title: Boundary Principles
summary: Alloy owns meaning, Foundry owns execution, Formation Briefs are the boundary, and neither semantics nor orchestration may leak across.
layer: leaf
parent: integration-architecture
tags: [boundary, principles, formation-brief]
---

# Boundary Principles

The boundary between the two systems is governed by five principles. They are what keep Alloy from becoming a second orchestrator and Foundry from having to understand Alloy's ontology. See [[ownership-boundary]] for how these are policed over time.

## Alloy owns meaning

Alloy owns the semantic interpretation of engineering intent:

- What capabilities the team wants to preserve.
- What threats may erode those capabilities.
- What expectations make those threats relevant.
- What strategies are preferred.
- What tradeoffs are accepted.
- What evidence would prove success.
- Which product and design intent are relevant.
- Which agent formations are appropriate.
- Which prompts should be compiled for each agent phase.
- Which follow-up questions should be asked of humans.

## Foundry owns execution

Foundry owns the operational reality of engineering automation:

- Event types and event emission.
- Task block execution.
- Observer vs Mutator semantics.
- Throttle behaviour.
- Gate resolution and gate execution.
- Retry behaviour.
- Agent invocation plumbing inside task blocks.
- Trace generation.
- Commit/push and other side effects.
- Maintenance, validation, vulnerability remediation, release, scan, and iteration formations.

## Formation Briefs are the boundary

The [[formation-brief|Formation Brief]] is the compiled package of intent for a run. It is the place where Alloy's rich semantic model becomes operationally consumable by Foundry.

The Formation Brief should be:

- Versioned.
- Immutable after compilation.
- Referenced by ID and digest.
- Human-readable enough for review.
- Machine-readable enough for Foundry and agents.
- Narrow enough that Foundry does not need Alloy's entire ontology.
- Rich enough to shape assessment, planning, execution, verification, and summarization.

## Avoid semantic leakage

Foundry should not need to know what a `Capability`, `Threat`, `Expectation`, `Strategy`, or `Tradeoff` means in Alloy's canonical model.

Foundry may need to know that a Formation Brief contains:

- Agent context sections.
- Prompt pack references.
- Gate overlay references.
- Runtime controls.
- Evidence plan references.
- Callback or reporting instructions.

But Alloy should translate its model into those Foundry-facing shapes.

## Avoid orchestration leakage

Alloy should not sequence Foundry internals directly.

Alloy should not say:

```text
Run Check Charter.
Then run Resolve Gates.
Then run Preflight.
Then run Assess Project.
Then run Create Plan.
```

Alloy should say:

```text
Emit an iteration_requested event for this project using this throttle, this payload, and this Formation Brief.
```

Foundry decides which task blocks fire.

## Related

- [[integration-architecture]] — section overview.
- [[ownership-boundary]] — keeping the boundary clean over time.
- [[formation-brief]] — the boundary artifact itself.
- [[system-roles]] — who owns what.

*Source: Integration Architecture §4 (Boundary Principles).*
