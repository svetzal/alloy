---
title: Learning Loop
summary: The closed loop from intent records through Foundry execution back to an updated intent graph, with the run_feedback output.
layer: leaf
parent: trace-feedback
tags: [feedback, loop, intent]
---

# Learning Loop

The learning loop closes the gap between accepted intent and running code. It carries [[engineering-intent-record]] records through a [[formation-brief]], into Foundry execution, and back out as an assessment that updates the intent graph — with [[record-lifecycle]] tracking each record's state along the way.

This is a leaf under [[trace-feedback]].

## The loop

```text
Intent records
  -> Formation brief
  -> Prompt and evidence packs
  -> Foundry execution
  -> Trace and gate results
  -> Intent satisfaction assessment
  -> Human review where needed
  -> Updated intent graph
```

Each pass refines the intent graph: satisfaction assessment and human review can confirm intent, surface missing intent, or flag intent that the run contradicted.

## run_feedback output

A completed pass produces a `run_feedback` record summarizing intent satisfaction, contradictions, and follow-up questions:

```yaml
run_feedback:
  trace_id: 4bf92f3577b34da6a3ce929d0e0e4736
  formation_brief_id: alloy.brief.checkout-payment.2026-06-06
  intent_satisfaction:
    - intent: alloy.intent.gateway.payment-provider
      status: satisfied
      evidence:
        - payment_vendor_import_boundary: passing
    - intent: alloy.intent.functional-core.checkout-policy
      status: partially_satisfied
      evidence:
        - domain_policy_tests: passing
        - liveview_handler_boundary: needs_review
  contradictions:
    - none
  follow_up_questions:
    - Should payment decline mapping be represented as typed domain errors?
```

*Source: Product Brief §19.*
