---
title: Drift Detection
summary: Detecting when the codebase no longer reflects accepted intent, and proposing a repair Formation Brief.
layer: leaf
parent: trace-feedback
tags: [feedback, drift, repair]
---

# Drift Detection

Intent drift occurs when the codebase no longer reflects accepted intent. The code has moved away from what was agreed, even though the intent itself is still valid.

This is a leaf under [[trace-feedback]].

## Worked example

```text
Intent:
  Vendor SDK imports stay inside adapter modules.

Observation:
  Stripe SDK imported directly in CheckoutLive.

Assessment:
  Drift detected.

Suggested action:
  Create Foundry Formation Brief for gateway-boundary repair.
```

## Resolving drift

When drift is detected the suggested action is a **repair Formation Brief** — Alloy proposes new work to bring the codebase back in line with accepted intent, rather than changing the intent. See [[workflow-detect-resolve-drift]] for the end-to-end flow, [[record-lifecycle]] for how the resulting records move through their states, and [[failure-handling]] for what happens when a repair run does not pass its gates.

Contrast this with [[contradiction-detection]], where the code is fine and it is the intent that is out of date.

*Source: Integration Architecture §16.3.*
