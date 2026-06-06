---
title: Alloy and Epilogue Tracker
summary: Epilogue Tracker owns product intent; Alloy consumes that context rather than duplicating it.
layer: leaf
parent: ecosystem
tags: [epilogue, product-intent, integration]
---

# Alloy and Epilogue Tracker

Within the [[ecosystem]], Epilogue Tracker remains responsible for product
intent. Alloy should consume Epilogue context, not duplicate it.

## Epilogue-owned questions

- Who are the actors?
- What goals do they have?
- What interactions help them meet those goals?
- What work supports those interactions?
- Which goals lack supporting work?
- Which interactions do not serve a user?
- Which connections are broken?

## Alloy-owned questions

- What engineering capabilities must be preserved while implementing this
  interaction?
- What threats does this product change introduce or increase?
- What engineering strategies should be preferred for this slice?
- What evidence should prove the work is safe and sustainable?
- What architectural or codebase tradeoffs should be considered?
- What guidance should agents receive before acting?

## Integration pattern

Alloy should be able to query or receive Epilogue context such as:

```yaml
product_intent:
  actor: Product owner
  goal: Clarify engineering intent for a software system
  interaction: Validate an extracted engineering intent hypothesis
  desired_outcome: Accepted intent record can guide future agent work
```

Alloy then resolves relevant engineering intent:

```yaml
engineering_intent:
  - Developers can validate extracted intent without editing YAML by hand
  - Hypothesized intent is not used as a hard runtime constraint
  - Accepted intent can be compiled into Foundry formation briefs
```

Foundry receives the compiled result, not raw product ambiguity. The
accepted engineering intent above is captured as an
[[engineering-intent-record]] and compiled into a [[formation-brief]].

## Why this protects Epilogue Tracker

Epilogue Tracker makes the right product move: work items should stay
focused on people, while technology decisions and constraints live as
guidance where tools can use them. Alloy is that guidance layer for
engineering intent.

This avoids fake user stories such as:

> "As a developer, I want a repository abstraction so that..."

That might occasionally be useful, but it is usually a smell. Alloy gives
those engineering concerns a better home — referencing Epilogue's product
model rather than re-expressing it as engineering work.

*Source: Product Brief §13 (Alloy and Epilogue Tracker); Integration Architecture §5.3.*
