---
title: Example Intent Records
summary: Four worked Engineering Intent Records — PostgreSQL infrastructure, a Phoenix LiveView boundary, a gateway abstraction, and the Four Rules of Simple Design.
layer: leaf
parent: engineering-intent
tags: [intent, examples, yaml]
---

# Example Intent Records

These four records show the six fields filled out against real projects. Each
pairs a capability with the threat, expectation, strategy, evidence, and tradeoff
that make the decision concrete.

## PostgreSQL as intentional infrastructure

```yaml
id: alloy.intent.postgresql.transactional-core
status: proposed
scope:
  project: epilogue-tracker
capability: Preserve strong consistency for core product-intent records
threat: Fragmented persistence causing inconsistent actor-goal-interaction links
expectation: Product intent relationships will become more interconnected over time
strategy: Use PostgreSQL as the primary relational datastore
evidence:
  - Actor, goal, interaction, and work links are transactionally updated
  - Data integrity constraints protect required relationships
  - Reporting queries can inspect relationship completeness
tradeoff: PostgreSQL should not become a dumping ground for unrelated event logs
review_trigger: Revisit if write volume or event-stream requirements dominate
```

## Phoenix LiveView boundary

```yaml
id: alloy.intent.liveview.functional-core
status: proposed
scope:
  technology: phoenix_liveview
capability: Test product-intent policy without UI lifecycle dependencies
threat: Business decisions embedded in LiveView event handlers
expectation: UI flows will change more frequently than domain policy
strategy: Functional Core / Imperative Shell with thin LiveView handlers
evidence:
  - Domain policy functions have direct tests
  - LiveView handlers delegate to application/domain functions
  - Domain tests do not require browser, socket, or database setup unless needed
tradeoff: Very simple CRUD screens may not justify additional separation
```

## Gateway abstraction

```yaml
id: alloy.intent.gateway.external-services
status: proposed
scope:
  project: alloy
capability: Replace external service integrations without changing core logic
threat: Vendor APIs, SDK types, or network concerns leaking into domain code
expectation: Agent providers, model APIs, and project tools will change frequently
strategy: Gateway abstractions for external services
evidence:
  - Vendor SDK imports isolated to adapter modules
  - Core logic depends on internal behaviours or protocols
  - Tests use fakes for external services
tradeoff: Avoid pass-through wrappers around stable internal modules
```

## Four Rules of Simple Design

```yaml
id: alloy.intent.simple-design
status: proposed
scope:
  project: all
capability: Keep the codebase easy to change by preserving local reasoning
threat: Premature abstraction, duplication fear, and unclear names hiding intent
expectation: Agents and humans will make frequent small changes
strategy: Apply Four Rules of Simple Design as a review heuristic
evidence:
  - Tests describe important behaviour
  - Names express domain intent
  - Duplication is removed when it reveals a stable abstraction
  - Small changes remain localized
tradeoff: Simplicity is contextual; do not remove duplication before the concept is clear
```

## Related

- [[engineering-intent-record]] — the six fields these examples fill in.
- [[record-lifecycle]] — what the `status: proposed` field means.

## Up

- [[engineering-intent]] — section overview.

*Source: Product Brief §28 (Example Intent Records).*
