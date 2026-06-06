---
title: Observability and Audit
summary: The audit questions every run must answer, the correlation chain across systems, and the brief-interpreted trace view shown to users.
layer: leaf
parent: integration-architecture
tags: [observability, audit, traces, correlation]
---

# Observability and Audit

## Audit questions

The integration should answer:

```text
Who approved this run?
What intent snapshot shaped the run?
Which prompt pack was used?
Which Foundry version executed it?
Which runner executed it?
Which repository revision was targeted?
Which gates were required?
Which gates passed or failed?
Which mutators executed versus simulated?
Which files changed?
Which commits were created?
Which capabilities were satisfied?
Which threats were observed?
Which evidence remains missing?
```

Many of these answers are carried on the [[foundry-run-result]].

## Event and trace correlation

Alloy and Foundry should preserve correlation across systems.

At minimum:

```text
Alloy run_request_id -> Foundry root trace_id -> block spans -> gate results -> run result -> Alloy evidence observations
```

This chain depends on the identifiers required by [[idempotency-and-correlation]]; without them the links cannot be reconstructed.

## User-facing trace view

Alloy should not merely show raw Foundry traces. It should interpret traces through the brief.

The user-facing view should answer:

```text
What did Foundry do?
Why did it do that?
Which intent was it serving?
What evidence did it collect?
What needs human attention?
```

This interpreted view is what feeds [[trace-feedback]] back into Alloy's understanding of intent.

*Source: Integration Architecture §19 (Observability and Audit).*
