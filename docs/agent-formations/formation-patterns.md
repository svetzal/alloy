---
title: Formation Patterns
summary: The six candidate agent formation patterns and when to use each.
layer: leaf
parent: agent-formations
tags: [formations, patterns, agents]
---

# Formation Patterns

These are the six candidate formation patterns Alloy can select among. Each
pairs a *social shape* for the agents with the conditions under which it is the
right choice. For how a formation is chosen, see [[agent-formations]].

## Solo implementer

Use for low-risk, localized, well-evidenced work.

Pattern:

```text
Coder -> Verify gates -> Summarize
```

## Planner-coder-reviewer

Use for normal feature or refactoring work.

Pattern:

```text
Planner -> Coder -> Intent reviewer -> Verify gates -> Summarize
```

## Archaeologist-interviewer

Use when intent is unclear.

Pattern:

```text
Code archaeologist -> Hypothesis generator -> Human interviewer
```

This should usually be read-only. The archaeologist role draws on
[[codebase-archaeology]] to reconstruct why the code is the way it is before
anyone proposes changing it.

## Red-team reviewer

Use when the strategy has a dangerous failure mode.

Example: gateway abstractions may prevent coupling, but can also create
indirection theatre.

Pattern:

```text
Planner -> Coder -> Simplicity skeptic -> Coder revision -> Verify gates
```

## Framework specialist

Use when the strategy is ecosystem-specific.

Example roles:

- Phoenix LiveView specialist.
- Elixir functional core specialist.
- Spring Boot architecture reviewer.
- Angular/RIG design-system specialist.
- Rust type-safety reviewer.

## Evidence specialist

Use when evidence is the main uncertainty.

Pattern:

```text
Planner -> Test/evidence designer -> Coder -> Gate verifier
```

The test/evidence designer and gate verifier roles exist to make the
[[evidence-and-gates|evidence and gates]] strong enough to trust the result.

---

Up: [[agent-formations]]

*Source: Product Brief §17 (Agent Formation Design).*
