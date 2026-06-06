---
title: Agent Formation Design
summary: How Alloy informs the social shape of agent work, not just its sequence.
layer: section
parent: index
tags: [formations, agents, design]
---

# Agent Formation Design

Alloy should inform agent formations. A formation is not just a sequence of
blocks; it is a *social shape* for agent work. The same task can be carried out
by a single coder, or by a planner handing off to a coder who is then
challenged by a skeptic — and which shape you choose changes what kinds of
mistakes are likely to survive.

This section connects to the broader pipeline: a formation is one of the things
the [[formation-brief-sections|agent_formation section]] of the brief selects,
and it is compiled into runnable guidance alongside the rest of the
[[prompt-pack-compilation|prompt pack]].

## Choosing a formation

The right formation is not fixed; it is a function of the work in front of you.
Alloy weighs the following inputs when selecting a formation:

- **Intent criticality** — how much rides on getting the intent right.
- **Confidence in extracted intent** — how sure we are we understood it.
- **Codebase risk** — how dangerous the surrounding code is to touch.
- **Number of affected capabilities** — the breadth of the blast radius.
- **Product/design ambiguity** — how unsettled the desired outcome is.
- **Prior trace failures** — what has gone wrong here before (see
  [[trace-feedback]]).
- **Required evidence strength** — how strong the proof of correctness must be
  (see [[evidence-and-gates]]).
- **Whether code modification is allowed** — read-only investigation versus
  change.

These inputs map onto concrete shapes in [[formation-patterns]], the six
candidate patterns ranging from a solo implementer to a red-team reviewer.

## The formation principle

The intent layer should not only say what agents should *prefer*. It should
also say what *failure modes* to watch for. A strategy without its known
pitfalls is half a strategy: it tells agents where to go but not where the
cliffs are. Naming the failure modes is also what lets a formation assign a
reviewer whose whole job is to guard against them — this is the bridge between
intent and the [[why-tradeoffs-matter|tradeoffs]] that make a strategy worth
choosing.

Example:

```yaml
strategy: Gateway abstraction
failure_modes:
  - Abstracting stable internal code prematurely
  - Creating pass-through wrappers with no semantic value
  - Hiding important vendor behaviour from the domain model
reviewer_role: simplicity_skeptic
```

Here the strategy carries its own antibodies: the listed failure modes justify
adding a `simplicity_skeptic` reviewer to the formation, turning a vague worry
into a structural safeguard.

See [[formation-patterns]] for the concrete patterns these inputs and
principles produce.

*Source: Product Brief §17 (Agent Formation Design).*
