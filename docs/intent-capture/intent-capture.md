---
title: Intent Capture
summary: How Alloy elicits tacit engineering judgement instead of asking developers to fill blank architecture forms.
layer: section
parent: index
tags: [intent, elicitation, archaeology]
---

# Intent Capture

Alloy must not ask developers to fill in blank architecture forms. The hard
part of capturing engineering intent is that most of it is tacit: it lives in a
senior engineer's judgement, in the failures they are trying not to repeat, and
in the shape of a codebase that no one ever wrote down. Alloy's job is to draw
that judgement out and turn it into durable [[engineering-intent-record|engineering intent records]].

There are two complementary ways Alloy does this.

## Elicitation through conversation

Alloy provides assistant features because developers often struggle to express
intent records directly. The assistant should feel like a thoughtful senior
engineer interviewing the developer, not like a form generator. See
[[elicitation-assistants]] for the six interview modes.

## Archaeology through observation

Alloy also extracts candidate intent from existing codebases, producing
hypotheses with confidence, observations, questions, and suggested records.
See [[codebase-archaeology]] for how this works, [[archaeology-signals]] for
the categories of evidence Alloy reads, and [[hypothesis-format]] for the shape
of what it produces.

Together these feed a single output: validated intent records that explain what
a capability protects and under what expectations a choice should be revisited.

*Source: Product Brief §11 (Intent Elicitation Features), §12 (Codebase Archaeology).*
