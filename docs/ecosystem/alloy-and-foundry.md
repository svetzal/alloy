---
title: Alloy and Foundry
summary: Foundry remains the execution runtime while Alloy owns engineering intent, with the Formation Brief as the integration artifact between them.
layer: leaf
parent: ecosystem
tags: [foundry, execution, formation-brief]
---

# Alloy and Foundry

In the [[ecosystem]], Foundry should remain the execution runtime. Alloy
should not compete with it.

## Foundry owns

- Event types and event emission.
- Task blocks.
- Observer vs Mutator semantics.
- Throttle behaviour.
- Gate resolution and execution.
- Agent invocation plumbing.
- Retry behaviour.
- Trace capture and rendering.
- Commit/push and workflow side effects.
- Maintenance, validation, and other operational formations.

## Alloy owns

- Engineering intent graph.
- Intent elicitation.
- Codebase archaeology.
- Human validation of intent hypotheses.
- Formation brief generation.
- Prompt pack compilation.
- Evidence plan generation.
- Gate overlay suggestions.
- Agent formation recommendations.
- Trace-to-intent feedback.
- Repo-local projections such as `CHARTER.md`, `AGENTS.md`, or generated
  context files.

## The key integration artifact: Formation Brief

A [[formation-brief]] is a compiled runtime package that tells Foundry what
intent should shape a run.

It is not a workflow engine. It is not a prompt. It is not an ADR. It is
the contextual contract between the intent systems and Foundry execution.

Foundry should be able to receive something like:

```json
{
  "formation_brief_id": "alloy.brief.checkout-payment-2026-06-06",
  "strategic": true,
  "max_iterations": 3,
  "actions": {
    "iterate": true,
    "maintain": false
  }
}
```

Then Foundry blocks that need richer context can resolve the brief from
Alloy or from a local compiled artifact.

## Why this fits Foundry's direction

Foundry's documented direction is to keep events and blocks strongly typed
in Rust while extracting the composition layer into configuration. Alloy
should be the product-level reason that extraction matters. Teams should
not need to recompile Foundry because they want a different agent
formation, different intent scope, different prompt pack, or different
evidence plan.

This is the same separation described in the [[integration-architecture]]:
Foundry is the event-driven engineering execution substrate — receiving
entry events, routing them to task blocks, applying throttle, running
observers and mutators, resolving gates, invoking agents, retrying bounded
failures, producing traces, and preserving execution safety and
auditability. Alloy compiles intent into the brief; Foundry runs it. See
[[ownership-boundary]] for the principle that frames this split.

*Source: Product Brief §14 (Alloy and Foundry); Integration Architecture §5.2.*
