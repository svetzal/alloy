---
title: The "Scar Tissue" Assistant
summary: Asks about past failures the developer is trying not to repeat.
layer: leaf
parent: elicitation-assistants
tags: [elicitation, assistants, failures]
---

# The "Scar Tissue" Assistant

This mode asks about past failures. Much of an engineer's architecture is shaped
by what went wrong on previous systems, and naming that pain makes the
underlying capability explicit.

## Example dialogue

Alloy:

> What failure from a previous system are you trying not to repeat here?

Developer:

> We had SQL everywhere and every schema change became a nightmare.

## Generated record

```yaml
capability: Change persistence structure without rewriting business logic
threat: Persistence details spreading through domain code
expectation: The data model will evolve as product understanding improves
strategy: Repository or gateway boundary around persistence
evidence:
  - SQL access isolated to persistence modules
  - Domain tests run without database access
  - Schema migrations do not require UI changes
tradeoff: Boundary can be unnecessary for simple read-only reporting paths
```

See the other modes in [[elicitation-assistants]]. The
[[assistant-why-is-this-here]] assistant works the same boundary from the other
direction, starting from the code that already exists.

*Source: Product Brief §11.3 (The "scar tissue" assistant).*
