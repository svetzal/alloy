---
title: The Alloy Ecosystem
summary: How Alloy sits among Epilogue Tracker, a future design intent system, and Foundry, with each owning a distinct layer of intent or execution.
layer: section
parent: index
tags: [ecosystem, intent, boundaries]
---

# The Alloy Ecosystem

Alloy does not stand alone. It occupies one layer in a stack of products,
each of which owns a different kind of intent or execution. The guiding
idea is that every concern lives where the tools that need it can use it,
and no product duplicates what a neighbour already owns.

## Who owns what

- **[[alloy-and-epilogue-tracker|Epilogue Tracker]]** owns *product
  intent*: actors, goals, interactions, outcomes, and work connected to
  human value.
- **[[design-intent-system|A future design intent system]]** should own
  *experience intent*: interaction behaviour, flows, affordances, tone,
  visual language, accessibility, and user experience constraints.
- **Alloy** owns *engineering intent*: capabilities to preserve, threats
  to avoid, expectations about change, preferred strategies, required
  evidence, and known tradeoffs.
- **[[alloy-and-foundry|Foundry]]** owns *execution*: events, task blocks,
  throttle, gate execution, agents, retry, traceability, commit/push,
  maintenance, and other engineering workflow runtime behaviour.

Alloy sits beside Epilogue Tracker and beside the design intent system as
peers in the intent space, and above Foundry, which executes against the
intent Alloy compiles.

## The boundary principle

The relationships across this stack rest on a single principle, detailed
in [[ownership-boundary]]:

> Alloy owns meaning. Foundry owns execution. Formation Briefs are the
> boundary.

Alloy references the intent its neighbours own rather than copying it, and
combines those references when it compiles a [[formation-brief]] for a run.

## Explore the relationships

- [[ownership-boundary]] — the central meaning-versus-execution split and
  why Alloy's ontology must evolve without recompiling Foundry.
- [[alloy-and-epilogue-tracker]] — how Alloy consumes product intent
  without duplicating it.
- [[alloy-and-foundry]] — what Foundry owns, what Alloy owns, and the
  Formation Brief as the integration artifact between them.
- [[design-intent-system]] — how Alloy will reference and combine
  experience intent once a design intent system exists.

*Source: Product Brief §4 (Relationship to existing products), §14; Integration Architecture §5.*
