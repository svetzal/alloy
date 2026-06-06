---
title: End-to-End Flows
summary: The four runtime flows that execute Alloy journeys against Foundry — validation-only, implement Epilogue interaction, intent drift repair, and strategic improvement.
layer: leaf
parent: workflows
tags: [runtime, flows, foundry, integration]
---

# End-to-End Flows

These four runtime flows show how Alloy journeys execute against Foundry. Each compiles a brief into a [[foundry-execution-request|Foundry Execution Request]], invokes Foundry through the configured [[integration-modes|integration mode]], and maps the [[foundry-run-result|Foundry Run Result]] back through [[trace-feedback|trace feedback]].

## Validation-only flow

```text
1. User selects a project in Alloy.
2. Alloy compiles current accepted engineering intent into a validation brief.
3. Alloy creates a Foundry Execution Request with entry_event=validation_requested and throttle=dry_run.
4. Runner invokes Foundry.
5. Foundry resolves gates and runs validation without mutators.
6. Runner posts Run Result back to Alloy.
7. Alloy reports which evidence is satisfied, missing, or unknown.
```

Use this when a user wants to know whether the current codebase reflects accepted intent before making changes.

## Implement Epilogue interaction flow

```text
1. User chooses an Epilogue interaction.
2. Alloy resolves relevant engineering intent records.
3. Alloy compiles a Formation Brief.
4. Alloy compiles Prompt Pack, Gate Overlay, and Evidence Plan.
5. Human reviews and approves dry-run.
6. Runner invokes Foundry with iteration_requested and strategic=true.
7. Foundry assesses, triages, plans, executes or simulates, verifies gates, and produces trace.
8. Alloy ingests result and maps it back to capabilities, threats, and evidence.
9. Human decides whether to authorize full mutation.
```

## Intent drift repair flow

```text
1. Alloy archaeology or Foundry trace detects drift.
2. Alloy proposes a repair brief.
3. Human reviews whether the accepted intent is still valid.
4. If valid, Alloy compiles a narrow repair Formation Brief.
5. Foundry runs a focused iteration.
6. Alloy records evidence and updates drift status.
```

## Strategic improvement flow

```text
1. User asks Alloy to improve a codebase while preserving accepted engineering intent.
2. Alloy compiles a strategic brief with max_iterations.
3. Foundry enters strategic iterate formation.
4. Each inner iteration reports back to the trace.
5. Alloy evaluates whether each iteration satisfied or changed intent.
6. Human reviews the summary before accepting or continuing.
```

See also the product-workflow view in [[workflows]].

*Source: Integration Architecture §21 (End-to-End Flow Examples).*
