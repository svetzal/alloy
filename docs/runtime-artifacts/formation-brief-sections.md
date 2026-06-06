---
title: Formation Brief — Required Sections
summary: The detailed sections every Formation Brief must carry, from identity through feedback hooks.
layer: leaf
parent: runtime-artifacts
tags: [formation-brief, sections, specification, intent]
---

# Formation Brief — Required Sections

A Formation Brief is a versioned, immutable artifact created for a specific run
or class of runs. This page details the sections every brief should carry. For
what a brief is and a full worked example, see [[formation-brief]].

## Identity

- Brief ID.
- Project.
- Created timestamp.
- Created by.
- Source intent graph version.
- Target Foundry project name.

## Mission

- Human-readable objective.
- Source product/design/engineering intent references.
- Definition of done.
- Stop conditions.

## Relevant intent

- Product intent from Epilogue.
- Design intent from the design system, when available.
- Engineering intent from Alloy.
- Known conflicts or unresolved questions.

## Protected capabilities

- Capabilities that must not be degraded.
- Severity or priority.
- Scope.
- Evidence required.

## Threats to watch

- Known risks the work is likely to introduce.
- Code patterns that would indicate drift.
- Past trace failure patterns.

## Strategies to prefer

- Approved patterns.
- Local definitions of those patterns.
- Example files or modules.
- Exceptions.

## Forbidden or suspicious moves

These should be used carefully. They should usually be warnings or gates, not
hard-coded commandments. Examples:

- Do not import vendor SDKs outside adapters.
- Do not put domain policy in LiveView handlers.
- Do not weaken gates to make a run pass.
- Do not broaden retry scope beyond the failing evidence.

## Evidence plan

The brief's [[evidence-plan|Evidence Plan]] covers:

- Tests to add or preserve.
- Static checks.
- Gate requirements.
- Trace expectations.
- Manual review questions.

## Agent formation

The recommended [[agent-formations|agent formation]]:

- Formation pattern.
- Roles.
- Capabilities.
- Access levels.
- Model preferences.
- Handoff expectations.

## Prompt pack references

References into the run's [[prompt-pack|Prompt Pack]]:

- Assessment prompt.
- Triage prompt.
- Planning prompt.
- Execution prompt.
- Retry prompt.
- Summarization prompt.

## Foundry runtime controls

- Entry event.
- Throttle recommendation.
- Max iterations.
- Gate profile.
- Whether maintenance should chain.
- Whether commit/push is allowed.

## Feedback hooks

- Which trace events Alloy should consume.
- Which evidence observations should update intent records.
- Which contradictions should be surfaced to humans.

## Example Formation Brief

```yaml
brief_id: alloy.brief.checkout-payment.2026-06-06
project: epilogue-tracker
created_at: 2026-06-06T00:00:00-04:00
source_graph_version: alloy.graph.v17

mission:
  objective: Implement the next checkout payment interaction from Epilogue.
  definition_of_done:
    - Product interaction acceptance checks pass
    - Required engineering evidence is collected
    - Foundry verify gates pass
  stop_conditions:
    - Required gates fail after retry budget
    - Product intent is ambiguous
    - Engineering intent records conflict

source_intent:
  product:
    - et.interaction.checkout.submit-payment
  design:
    - design.intent.checkout.error-recovery
  engineering:
    - alloy.intent.functional-core.checkout-policy
    - alloy.intent.gateway.payment-provider
    - alloy.intent.typed-errors.payment-failure

protected_capabilities:
  - name: Test checkout policy without UI or external services
    severity: high
  - name: Replace payment provider without changing domain logic
    severity: high
  - name: Preserve stable payment failure semantics
    severity: medium

threats_to_watch:
  - Business rules added to LiveView handlers
  - Vendor SDK imports outside payment adapters
  - Stringly typed payment errors

strategies_to_prefer:
  - Functional Core / Imperative Shell
  - Gateway abstraction
  - Typed domain errors
  - Four Rules of Simple Design

forbidden_moves:
  - Do not weaken existing tests or gates to pass verification
  - Do not introduce direct vendor SDK dependencies in domain modules
  - Do not move payment decision logic into UI handlers

evidence_plan:
  required:
    - Domain payment policy tests pass without UI or network
    - Static import boundary check passes
    - Existing product acceptance checks pass
  suggested:
    - Add fake payment gateway test coverage for decline cases

agent_formation:
  pattern: planner_coder_intent_reviewer
  roles:
    - name: engineering_intent_reviewer
      access: read_only
    - name: phoenix_liveview_specialist
      access: full
    - name: test_evidence_reviewer
      access: read_only

foundry_runtime:
  entry_event: iteration_requested
  throttle: dry_run_first_then_full
  max_iterations: 3
  actions:
    iterate: true
    maintain: false
```

## Related

- [[formation-brief]] — what a brief is and why it fits Foundry.
- [[agent-formations]], [[evidence-plan]], [[prompt-pack]] — sections that point
  to their own artifacts.

*Source: Product Brief §15.*
