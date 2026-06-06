---
title: Vision
summary: Alloy is an engineering intent management layer and runtime control plane that turns tacit engineering judgement into structured guidance for autonomous software work.
layer: section
parent: index
tags: [vision, positioning, overview]
---

# Vision

Alloy is a proposed engineering intent management layer that sits above
[[alloy-and-foundry|Foundry]] and beside [[alloy-and-epilogue-tracker|Epilogue Tracker]].
Epilogue Tracker captures product intent (who the system helps and what goals
those actors have); Foundry executes engineering work as event-driven
formations of task blocks, gates, agents, and traces. Alloy fills the missing
layer between them: the explicit, structured expression of [[engineering-intent]].

The central thesis is that product intent says what people need the software to
make possible, while engineering intent says what capabilities the codebase and
team must retain as the software changes. Alloy models that intent as records of
capabilities, threats, expectations, strategies, evidence, and tradeoffs —
turning tacit developer judgement into a form that agents, formations, gates,
prompt packs, and humans can all use.

Positioned as an engineering intent management system and runtime control plane,
Alloy borrows from requirements tools, ADRs, prompt libraries, and workflow
engines but has a more specific job: it captures engineering intent from
developers and codebases, compiles it into [[alloy-and-foundry|Foundry]]
formation briefs, and carries the resulting guidance into autonomous execution.
It does not replace [[alloy-and-foundry|Foundry]], [[alloy-and-epilogue-tracker|Epilogue Tracker]],
or the [[design-intent-system|design intent system]] — it complements all three
through a clear [[ecosystem|ownership boundary]].

## In this section

- [[executive-summary]] — what Alloy is and the three artifacts it first produces.
- [[product-thesis]] — why autonomous delivery needs explicit engineering intent.
- [[product-positioning]] — category, relationships, and the one-line promise.
- [[problem-statement]] — the abstraction gap Alloy closes.
- [[target-users-and-jobs]] — who uses Alloy and the jobs they need done.
- [[product-goals]] — what Alloy should accomplish.
- [[non-goals]] — what Alloy deliberately will not be.
- [[product-narrative]] — the short, plain-language story of Alloy.

*Source: Product Brief §1, §3, §4 (Executive Summary, Product Thesis, Product Positioning).*
