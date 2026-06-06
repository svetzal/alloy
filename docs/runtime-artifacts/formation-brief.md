---
title: Formation Brief
summary: The compiled, immutable contextual contract that tells Foundry what intent should shape a run.
layer: leaf
parent: runtime-artifacts
tags: [formation-brief, contract, intent, integration]
---

# Formation Brief

A Formation Brief is the main runtime artifact in the
[[runtime-artifacts|runtime artifact family]]. It is a compiled runtime package
that tells Foundry what intent should shape a run.

## What it is — and is not

A Formation Brief is **not** a workflow engine, **not** a prompt, and **not** an
ADR. It is the *contextual contract* between the intent systems and Foundry
execution. It is the artifact a human should be able to review before
authorizing a run.

It carries identity and version, source intent references, the mission, the
capabilities the run must protect, the threats to watch, the strategies to
prefer, forbidden or suspicious moves, evidence requirements, an agent formation
recommendation, references to a [[prompt-pack|Prompt Pack]] and
[[gate-overlay|Gate Overlay]], Foundry runtime controls, and feedback hooks. For
the full breakdown of every section, see [[formation-brief-sections]].

## Why this fits Foundry's direction

Foundry's documented direction is to keep events and blocks strongly typed in
Rust while extracting the composition layer into configuration. Alloy is the
product-level reason that extraction matters: teams should not need to recompile
Foundry because they want a different agent formation, a different intent scope,
a different prompt pack, or a different evidence plan. The Formation Brief is how
that intent is supplied as configuration.

## How a run references a brief

Foundry can receive something as small as this and then resolve the full brief
from Alloy or from a local compiled artifact when a block needs richer context:

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

The narrow request that actually triggers a run is the
[[foundry-execution-request|Foundry Execution Request]], which references the
brief by id, version, and digest.

## Worked example

A full compiled Formation Brief in its `alloy.formation_brief.v1` schema:

```yaml
schema_version: alloy.formation_brief.v1
id: brief_01HZ_CHECKOUT_PAYMENT
version: 1
digest: sha256:example
project_id: checkout-service
created_at: 2026-06-06T10:00:00-04:00
created_by: stacey
status: compiled

mission:
  objective: Implement the checkout payment interaction from Epilogue Tracker.
  product_intent_refs:
    - epilogue.interaction.checkout.submit-payment
  design_intent_refs:
    - design.checkout.error-recovery
  engineering_intent_refs:
    - alloy.intent.payment-provider-gateway
    - alloy.intent.liveview-functional-core
    - alloy.intent.typed-domain-errors

protected_capabilities:
  - id: alloy.capability.replace-payment-provider
    statement: Payment providers can be replaced without changing domain checkout rules.
  - id: alloy.capability.test-rules-without-ui
    statement: Checkout business rules can be tested without LiveView or external services.

threats_to_watch:
  - Vendor SDK leaking into LiveView or domain modules.
  - Payment failure semantics becoming ad hoc strings.
  - Business decisions moving into LiveView event handlers.

preferred_strategies:
  - Gateway abstraction around payment providers.
  - Functional Core / Imperative Shell.
  - Typed domain errors.

forbidden_moves:
  - Do not import vendor SDK modules outside payment adapters.
  - Do not put payment policy branching in LiveView handlers.
  - Do not remove or weaken existing payment tests to pass gates.

tradeoffs:
  - Gateway abstraction adds boundary code; avoid generalizing beyond current provider needs.
  - Functional core should remain simple and not become a framework inside the app.

evidence_plan:
  required:
    - Domain tests cover payment decision rules without LiveView.
    - Vendor imports are isolated to adapters.
    - Payment failure outcomes use internal typed values.
    - Foundry verification gates pass after execution.

prompt_pack:
  id: prompt_pack_01HZ_CHECKOUT_PAYMENT
  digest: sha256:example

foundry:
  entry_event: iteration_requested
  throttle: dry_run
  payload:
    strategic: true
    max_iterations: 3
    actions:
      iterate: true
      maintain: false

feedback_hooks:
  on_completed:
    - create_evidence_observations
    - summarize_intent_satisfaction
    - propose_follow_up_questions
```

## Minimal JSON shape

The minimal Formation Brief structure, useful as a starting template:

```json
{
  "brief_id": "alloy.brief.example",
  "project": "example-project",
  "mission": {
    "objective": "Implement selected Epilogue interaction",
    "definition_of_done": []
  },
  "source_intent": {
    "product": [],
    "design": [],
    "engineering": []
  },
  "protected_capabilities": [],
  "threats_to_watch": [],
  "strategies_to_prefer": [],
  "forbidden_moves": [],
  "evidence_plan": {
    "required": [],
    "suggested": []
  },
  "agent_formation": {
    "pattern": "planner_coder_reviewer",
    "roles": []
  },
  "prompt_packs": {
    "assessment": "alloy.prompt.assessment.example",
    "triage": "alloy.prompt.triage.example",
    "planning": "alloy.prompt.planning.example",
    "execution": "alloy.prompt.execution.example",
    "retry": "alloy.prompt.retry.example",
    "summary": "alloy.prompt.summary.example"
  },
  "foundry_runtime": {
    "entry_event": "iteration_requested",
    "throttle": "dry_run",
    "max_iterations": 3,
    "actions": {
      "iterate": true,
      "maintain": false
    }
  }
}
```

## Related

- [[formation-brief-sections]] — the detailed required sections.
- [[formation-brief-lifecycle]] — how a brief moves from draft to immutable.
- [[prompt-pack]] and [[evidence-plan]] — artifacts referenced from a brief.
- [[gate-overlay]] — gates a brief proposes for the run.

*Source: Product Brief §14, Appendix A; Integration Architecture §7.1, §25.*
