---
title: Risks and Countermeasures
summary: The six product risks Alloy is designed to defend against, with countermeasures for each.
layer: leaf
parent: reference
tags: [risks, countermeasures, design]
---

# Risks and Countermeasures

Six risks shape Alloy's design. Each is paired with concrete countermeasures
built into the product. Up to [[reference]].

## Risk: The model becomes a truism collector

Developers may enter vague statements like "keep it simple" or "write good
code."

Countermeasures:

- Require capability, threat, expectation, evidence, and tradeoff.
- Ask "what would violate this?"
- Ask "how would we know?"
- Ask "when would this strategy be too much?"

This is the same discipline described in [[why-tradeoffs-matter]].

## Risk: Agents over-apply principles

An agent may use accepted intent as an excuse to introduce ceremony.

Countermeasures:

- Include tradeoffs and failure modes in prompts.
- Use red-team or simplicity reviewer formations.
- Gate for evidence, not pattern presence.

## Risk: Codebase archaeology hallucinates intent

The system may infer intent from accidental structure.

Countermeasures:

- Call outputs hypotheses (see the [[hypothesis-format|hypothesis format]]).
- Require observations.
- Keep confidence visible.
- Require human acceptance before runtime use.

## Risk: Alloy duplicates Epilogue Tracker

Alloy could start modelling actors and goals.

Countermeasures:

- Treat Epilogue as source of product intent.
- Store references to Epilogue entities rather than copies where possible.
- Keep Alloy records focused on engineering capabilities.

This boundary is the subject of [[alloy-and-epilogue-tracker]].

## Risk: Alloy bloats Foundry

The integration could push semantic complexity into Foundry events and blocks.

Countermeasures:

- Pass references, not giant semantic payloads.
- Keep Foundry as runtime.
- Keep Alloy as semantic compiler/control plane.

This is the [[ownership-boundary]] in practice.

## Risk: Intent becomes stale

Engineering intent changes as the codebase, team, and product change.

Countermeasures:

- Use trace feedback.
- Detect drift (see [[drift-detection]]).
- Add review triggers.
- Make supersession and deprecation normal.

## Risk: Developers reject the product as documentation burden

The product will fail if it feels like filling in architecture forms.

Countermeasures:

- Lead with assistant extraction.
- Generate hypotheses from code.
- Use conversational review.
- Make records useful immediately by compiling them into Foundry work.

*Source: Product Brief §27 (Risks and Product Countermeasures).*
