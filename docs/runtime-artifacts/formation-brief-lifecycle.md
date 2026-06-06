---
title: Formation Brief Lifecycle
summary: The states a Formation Brief passes through, why compiled briefs are immutable, and how templates differ from compiled instances.
layer: leaf
parent: runtime-artifacts
tags: [formation-brief, lifecycle, immutability, runtime]
---

# Formation Brief Lifecycle

A [[formation-brief]] is the compiled, self-contained artifact that drives a single Foundry run. Its lifecycle exists to enforce one core property: **briefs should be immutable after compilation**. The underlying intent graph remains living and editable, but each run must be tied to the exact intent snapshot used at execution time.

## States

A brief moves through a sequence of states from assembly to archival:

- **Draft** — A user or assistant is assembling the intended scope. The brief is not ready for execution.
- **Reviewable** — The brief has enough structure for human review. It includes source intent, protected capabilities, strategies, evidence, and runtime controls.
- **Approved** — A human with authority has approved the brief for a particular execution mode. (See [[security-and-authority]] for who may approve what.)
- **Compiled** — All references have been resolved. Prompt Packs, Gate Overlays, Evidence Plans, and Foundry runtime controls have been produced.
- **Queued** — A Foundry Execution Request has been created and is awaiting runner pickup or Foundry acceptance.
- **Accepted** — Foundry or the runner has accepted the request and recorded the brief ID, digest, and idempotency key.
- **Executing** — Foundry is running the requested formation.
- **Completed** — Foundry has produced a terminal result.
- **Analyzed** — Alloy has interpreted the result against the original intent and updated evidence observations.
- **Archived** — The brief remains available for audit but is no longer active.

The transition from Reviewable through Approved to Compiled is where the brief becomes fixed. The Queued and Accepted states record the handoff to the runtime, including the idempotency key and digest that bind a run to a specific brief (see [[idempotency-and-correlation]]). The Analyzed state is where the run's outcome flows back into living intent.

## Immutable brief principle

A brief may reference living intent records, but the compiled brief must contain or snapshot the values needed for execution.

Otherwise, a later intent edit could rewrite the meaning of an earlier run. The compiled artifact is the contract for what was actually requested, and audit depends on it not shifting underneath completed work.

## Templates versus compiled instances

Some briefs may become templates. A template is mutable. A compiled brief instance is not.

```text
Template:
  Implement next Epilogue interaction using Phoenix/LiveView intent baseline.

Compiled instance:
  Implement checkout payment interaction using intent snapshot A at repo revision B.
```

A template captures a reusable shape of intent; a compiled instance pins that shape to a concrete snapshot and revision, which is what makes it executable and auditable.

## Related

- [[formation-brief]] — the artifact itself
- [[formation-brief-sections]] — what a brief contains
- [[idempotency-and-correlation]] — how runs are bound to briefs
- [[security-and-authority]] — approval authority for execution modes
- [[runtime-artifacts]] — section overview

*Source: Integration Architecture §8.*
