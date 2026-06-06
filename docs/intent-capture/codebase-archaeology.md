---
title: Codebase Archaeology
summary: How Alloy extracts candidate engineering intent from existing codebases as hypotheses, not facts.
layer: leaf
parent: intent-capture
tags: [archaeology, intent, hypotheses]
---

# Codebase Archaeology

Alloy should extract candidate engineering intent from existing codebases. Most
codebases already encode a great deal of judgement in their structure, history,
and tests; archaeology reads that judgement back out.

The output should be a set of hypotheses with confidence, observations,
questions, and suggested records. Alloy reads several
[[archaeology-signals|categories of signal]] to form those hypotheses, and emits
them in a consistent [[hypothesis-format]].

Crucially, extracted intent is never asserted as fact. Each hypothesis defaults
to **Hypothesized** until a developer validates it — see [[record-lifecycle]]
for how a hypothesis is promoted into an accepted
[[engineering-intent-record]].

## Archaeology principles

- Label findings as hypotheses, not facts.
- Prefer questions over declarations when confidence is not high.
- Trace each hypothesis to concrete observations.
- Avoid praising the codebase for generic patterns without knowing why they
  exist.
- Do not infer "best practice" when the code may simply be accidental.
- Give developers quick accept/edit/reject paths.

Return to [[intent-capture]] for the conversational counterpart,
[[elicitation-assistants]].

*Source: Product Brief §12 (Codebase Archaeology), including Archaeology principles.*
