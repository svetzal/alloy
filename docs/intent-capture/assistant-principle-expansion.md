---
title: The Principle-Expansion Assistant
summary: Starts from a known principle and asks for its local meaning in this codebase.
layer: leaf
parent: elicitation-assistants
tags: [elicitation, assistants, principles]
---

# The Principle-Expansion Assistant

This mode starts from a known principle and asks for local meaning. A principle
like Functional Core / Imperative Shell means different things in different
codebases; the assistant grounds it in this one.

## Example dialogue

Alloy:

> You selected Functional Core / Imperative Shell. In this codebase, what counts
> as core, what counts as shell, and what violations should agents avoid?

## What the assistant produces

- Contextual definition.
- Examples of desired structure.
- Examples of violations.
- Evidence/gate candidates.
- Tradeoffs and exceptions.

The violation examples and evidence candidates feed directly into
[[evidence-and-gates]]. See the other modes in [[elicitation-assistants]]; the
[[assistant-what-makes-you-angry]] assistant is a natural complement for drawing
out the violations that matter.

*Source: Product Brief §11.5 (The principle-expansion assistant).*
