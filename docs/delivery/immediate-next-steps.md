---
title: Immediate Next Steps
summary: A consolidated, de-duplicated list of the concrete first actions for Alloy, drawn from both source documents.
layer: leaf
parent: delivery
tags: [next-steps, planning, contracts, demo]
---

# Immediate Next Steps

Both source documents independently arrived at a similar set of first moves:
define the first runtime contracts, build a projection-only MVP, choose a first
runner, pick one real codebase and one Epilogue interaction for an end-to-end
demo, and keep dry-run as the default. The lists below are merged and
de-duplicated.

## Define the first runtime contracts

1. Treat the revised product brief and the companion integration architecture as
   the initial document set, and add a short runtime architecture summary to the
   brief.
2. Turn the product brief into separate specifications for Engineering Intent
   Records and [[formation-brief|Formation Briefs]].
3. Define `FormationBrief v1` as the first real contract (see
   [[formation-brief]]).
4. Define `FoundryExecutionRequest v1` as the first Foundry-facing contract (see
   [[foundry-execution-request]]).
5. Define `FoundryRunResult v1` (see [[foundry-run-result]]).
6. Define the minimum Phoenix/LiveView Alloy data model.

## Build the projection-only MVP

7. Build a projection-only [[mvp]] that emits `.alloy/` artifacts and uses
   existing Foundry prompt or strategic prompt mechanisms — the first
   integration mode, projection through generated prompt packs and formation
   brief YAML.
8. Add a minimal trace/result import screen to Alloy.
9. Draft three assistant interview flows.

## Choose the first runner and demo

10. Decide whether the first runner is an Alloy CLI, a small Elixir mix task, a
    Rust helper, or a Foundry subcommand.
11. Choose one real codebase as an archaeology pilot.
12. Define one end-to-end demonstration using one real codebase and one Epilogue
    interaction:
    - Select an Epilogue interaction.
    - Capture or select engineering intent.
    - Generate a formation brief.
    - Run Foundry dry-run.
    - Review trace feedback.

## Defaults and open decisions

13. Use dry-run as the default until digest verification, idempotency, and run
    result ingestion are working.
14. Decide whether `CHARTER.md` becomes a generated projection, remains
    hand-authored, or is hybrid.
15. Define the first evidence/gate overlay format.

Several of these decisions remain unresolved — see [[open-questions]].

Up: [[delivery]]

*Source: Product Brief §32 (Immediate Next Steps); Integration Architecture §28 (Immediate Next Steps).*
