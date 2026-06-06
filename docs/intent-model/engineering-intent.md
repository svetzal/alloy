---
title: Engineering Intent Records
summary: The core Alloy object is the Engineering Intent Record, a future-facing engineering judgement that ties a capability to the threats, expectations, strategies, evidence, and tradeoffs around it.
layer: section
parent: index
tags: [intent, core-concept, records]
---

# Engineering Intent Records

The core Alloy object is the **Engineering Intent Record**. A record expresses a
future-facing engineering judgement:

> We need to preserve this capability because this threat matters under this
> expectation, so we prefer this strategy, require this evidence, and accept
> this tradeoff.

Rather than capturing a rule in the abstract, a record holds an engineering
decision together with its reasoning and its costs, so the decision stays
contextual and can be evaluated, enforced, and revisited over time.

## In this section

- [[engineering-intent-record]] — the record object and its six fields, with
  examples and a minimal JSON shape.
- [[why-tradeoffs-matter]] — why the tradeoff field is what keeps records from
  decaying into truisms.
- [[record-lifecycle]] — the states a record moves through, from Hypothesized to
  Superseded, and the principles that govern transitions.
- [[example-intent-records]] — four worked examples drawn from real projects.

## Related

- [[intent-capture]] — how records are elicited from conversations, codebases,
  and traces.
- [[formation-brief]] — where accepted records are compiled into work guidance.
- [[data-model]] — how records and their relationships are represented.

*Source: Product Brief §9 (Core Concept: Engineering Intent Records).*
