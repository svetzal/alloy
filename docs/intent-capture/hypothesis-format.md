---
title: Hypothesis Format
summary: The YAML shape Alloy emits for an archaeology hypothesis and how hypotheses become records.
layer: leaf
parent: codebase-archaeology
tags: [archaeology, hypotheses, format]
---

# Hypothesis Format

[[codebase-archaeology|Archaeology]] emits each candidate intent as a structured
hypothesis. The format carries a confidence score, the concrete observations
behind it, the possible intent it implies, and the open questions a developer
must answer.

```yaml
hypothesis_id: alloy.hypothesis.checkout.payment-gateway
confidence: 0.82
observed:
  - PaymentGateway behaviour used by checkout domain code
  - Stripe adapter isolates vendor SDK imports
  - Fake gateway used in domain tests
possible_intent:
  capability: Replace payment providers without changing domain logic
  threat: Vendor SDK churn leaking through checkout code
  expectation: Payment integrations will change over time
  strategy: Gateway abstraction with test fake
questions:
  - Is this primarily for provider replaceability or test isolation?
  - Are multiple providers expected, or is this defensive architecture?
  - Should this boundary be enforced by a gate?
suggested_next_action: Ask developer to validate hypothesis
```

## From hypothesis to record

The `observed` list is drawn from the [[archaeology-signals|signal categories]].
The `possible_intent` block mirrors the shape of an
[[engineering-intent-record]], so a validated hypothesis can be promoted with
minimal rework.

A hypothesis is never an accepted record on its own. Its
`suggested_next_action` typically asks the developer to validate it, and only
then does it move from **Hypothesized** to accepted along the
[[record-lifecycle]].

*Source: Product Brief §12 (Hypothesis format).*
