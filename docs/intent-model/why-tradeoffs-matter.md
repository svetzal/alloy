---
title: Why Tradeoffs Matter
summary: The tradeoff field forces every principle to stay contextual, preventing records from decaying into truisms that agents over-apply.
layer: leaf
parent: engineering-intent
tags: [intent, tradeoff, rationale]
---

# Why Tradeoffs Matter

Without tradeoffs, Alloy will collect truisms. Developers will accept them
because they sound correct, but agents will over-apply them. The tradeoff field
forces every principle to remain contextual.

Compare two records:

- A record that says "prefer gateway abstractions" is weak.
- A record that says "prefer gateway abstractions for volatile external
  providers, with the tradeoff that premature abstraction is harmful for stable
  internal modules" is useful.

The second record tells an agent or developer not just what to do, but when the
strategy stops paying off. That boundary is exactly what keeps the principle from
being applied everywhere by reflex.

## Related

- [[engineering-intent-record]] — the Tradeoff field is one of the six fields of
  every record.

*Source: Product Brief §9 (Why tradeoff is essential).*
