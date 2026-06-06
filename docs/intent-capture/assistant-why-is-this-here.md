---
title: The "Why is this here?" Assistant
summary: Inspects code structures and asks targeted questions about why a boundary exists.
layer: leaf
parent: elicitation-assistants
tags: [elicitation, assistants, boundaries]
---

# The "Why is this here?" Assistant

This mode inspects code structures and asks targeted questions. It points at a
concrete arrangement of code and asks the developer to name the intent behind
it.

## Example dialogue

Alloy:

> I found `PaymentGateway`, `StripePaymentAdapter`, and fake gateway tests. Is
> this boundary intended to protect provider replaceability, testability, or
> something else?

Developer:

> Mostly provider churn and test isolation. We have been burned by SDK changes.

## Generated record

```yaml
capability: Replace payment providers without changing domain logic
threat: Vendor SDK churn leaking through checkout code
expectation: Payment integrations will change over time
strategy: Gateway abstraction with fake implementations in tests
evidence:
  - Vendor SDK imports isolated to adapter modules
  - Checkout tests use fake gateway
  - Domain payment outcomes use internal types
tradeoff: Boundary code adds overhead for stable providers
```

See the other modes in [[elicitation-assistants]], and the
[[assistant-scar-tissue]] assistant, which probes the failures behind this kind
of defensive boundary.

*Source: Product Brief §11.1 (The "Why is this here?" assistant).*
