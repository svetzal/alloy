---
title: Product Positioning
summary: Alloy is an engineering intent management system and runtime control plane that owns engineering intent alongside Epilogue Tracker, the design intent system, and Foundry.
layer: leaf
parent: vision
tags: [vision, positioning, ecosystem]
---

# Product Positioning

## Category

Alloy is an engineering intent management system and runtime control plane for
agentic software engineering.

It is not a traditional requirements tool, ADR tool, static architecture
repository, prompt library, or workflow engine. It borrows from all of those,
but its job is more specific:

> Alloy turns tacit engineering judgement into structured runtime guidance for
> autonomous engineering work.

## Relationship to existing products

**[[alloy-and-epilogue-tracker|Epilogue Tracker]]** owns product intent: actors,
goals, interactions, outcomes, and work connected to human value.

**[[design-intent-system|Design intent system]]** should own experience intent:
interaction behaviour, flows, affordances, tone, visual language, accessibility,
and user experience constraints.

**Alloy** owns [[engineering-intent|engineering intent]]: capabilities to
preserve, threats to avoid, expectations about change, preferred strategies,
required evidence, and known tradeoffs.

**[[alloy-and-foundry|Foundry]]** owns execution: events, task blocks, throttle,
gate execution, agents, retry, traceability, commit/push, maintenance, and other
engineering workflow runtime behaviour.

See the [[ecosystem]] section for the full ownership boundary across these systems.

## One-line promise

Alloy helps developers make their engineering judgement explicit enough that
agents can act on it without turning that judgement into a brittle pile of
hard-coded workflows and prompts.

## Short positioning statement

For teams using agents to build and evolve software, Alloy captures engineering
intent from developers and codebases, compiles that intent into Foundry
[[formation-brief|formation briefs]], and carries the resulting guidance into
autonomous execution through [[prompt-pack|prompts]], gates, agent formations,
and trace feedback.

---

Related: [[vision]] · [[ecosystem]] · [[product-thesis]] · [[non-goals]]

*Source: Product Brief §4 (Product Positioning).*
