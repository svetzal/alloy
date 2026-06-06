---
title: The "What Would Make You Angry?" Assistant
summary: Surfaces intent by asking which changes the developer would reject outright.
layer: leaf
parent: elicitation-assistants
tags: [elicitation, assistants, violations]
---

# The "What Would Make You Angry?" Assistant

Developers often express intent more clearly by identifying violations. Asking
what they would never accept reveals the boundary they care about more sharply
than asking them to describe it in the abstract.

## Example dialogue

Alloy:

> What change would make you reject a PR immediately?

Developer:

> If someone puts business rules in LiveView handlers, I am rejecting it.

## Generated record

```yaml
capability: Test business rules without the UI lifecycle
threat: Domain decisions embedded in LiveView event handlers
expectation: UI flows will change more often than domain policy
strategy: Functional core behind a thin LiveView shell
evidence:
  - LiveView handlers delegate to domain functions
  - Domain functions are tested directly
  - UI tests focus on wiring and rendering
tradeoff: Some simple screens may not need a separate domain layer
```

See the other modes in [[elicitation-assistants]]. The
[[assistant-principle-expansion]] assistant goes deeper on what counts as a
violation of a stated principle like Functional Core / Imperative Shell.

*Source: Product Brief §11.2 (The "What would make you angry?" assistant).*
