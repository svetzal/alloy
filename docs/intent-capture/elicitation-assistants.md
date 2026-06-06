---
title: Elicitation Assistants
summary: The six interview modes Alloy uses to draw tacit engineering intent out of developers.
layer: section
parent: intent-capture
tags: [intent, elicitation, assistants]
---

# Elicitation Assistants

Alloy needs assistant features because developers may struggle to express
intent records directly. The assistant should feel like a thoughtful senior
engineer interviewing the developer, not like a form generator.

Each mode approaches the same goal from a different angle, and each produces or
sharpens an [[engineering-intent-record|engineering intent record]].

## The six modes

- [[assistant-why-is-this-here]] — inspects code structures and asks targeted
  questions about why a boundary exists.
- [[assistant-what-makes-you-angry]] — surfaces intent by asking which changes
  the developer would reject outright.
- [[assistant-scar-tissue]] — asks about past failures the developer is trying
  not to repeat.
- [[assistant-technology-choice]] — starts from a stated technology choice and
  extracts the deeper capability it protects.
- [[assistant-principle-expansion]] — starts from a known principle and asks
  for its local meaning in this codebase.
- [[assistant-contradiction]] — notices when accepted intent conflicts with
  code, gates, or other intent.

Return to [[intent-capture]] for the broader picture, including
[[codebase-archaeology]].

*Source: Product Brief §11 (Intent Elicitation Features).*
