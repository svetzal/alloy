---
title: Non-Functional Requirements
summary: The qualities Alloy must exhibit, from trustworthiness to resilience against over-abstraction.
layer: leaf
parent: reference
tags: [requirements, non-functional, quality]
---

# Non-Functional Requirements

These are the qualities Alloy must exhibit across everything in
[[functional-requirements]]. Up to [[reference]].

## Trustworthiness

Alloy must be explicit about confidence. It should not present inferred intent
as fact.

## Traceability

Every active record should have sources. Every formation brief should reference
which intent records it compiled. Every trace feedback assessment should link
back to the Foundry trace or event ID.

## Low friction

Developers should be able to accept, edit, or reject hypotheses quickly. If the
system feels like architecture paperwork, it will fail. The
[[record-lifecycle|record lifecycle]] is built around fast, conversational
review for exactly this reason.

## Runtime safety

Hypothesized intent should not silently become a hard execution constraint.
High-risk constraints should be enforced through accepted records and explicit
evidence.

## Extensibility

The model should support new intent types, strategies, evidence kinds, agent
roles, and formation patterns without database or code churn every time.

## Local-first projection

Foundry and agents often need local context. Alloy should be able to project
intent into repo-local files while keeping the canonical graph structured and
queryable.

## Explainability

When Alloy recommends a formation, prompt, gate, or reviewer role, it should
explain which intent records caused that recommendation.

## Resilience to over-abstraction

Alloy should actively ask about tradeoffs and failure modes. It should be
willing to recommend against a strategy when the context does not support it —
the discipline described in [[why-tradeoffs-matter]].

*Source: Product Brief §26 (Non-Functional Requirements Seed).*
