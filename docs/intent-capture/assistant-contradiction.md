---
title: The Intent Contradiction Assistant
summary: Notices when accepted intent conflicts with code, gates, or other intent.
layer: leaf
parent: elicitation-assistants
tags: [elicitation, assistants, drift]
---

# The Intent Contradiction Assistant

This mode notices when accepted intent conflicts with code, gates, or other
intent. It is part of keeping the intent graph honest as the codebase moves.

## Example dialogue

Alloy:

> Accepted intent says vendor SDK imports should be isolated to adapters. The
> current code imports `Stripe` directly inside `CheckoutLive`. Is this an
> intentional exception, drift, or a sign that the intent record is too broad?

## The goal

The goal is not to shame the developer. It is to keep the intent graph alive. A
contradiction may resolve into an accepted exception, a flagged drift, or a
refinement of an over-broad record — each of which moves a record along its
[[record-lifecycle]].

This assistant is the conversational front end to ongoing
[[contradiction-detection]]. See the other modes in
[[elicitation-assistants]].

*Source: Product Brief §11.6 (The intent contradiction assistant).*
