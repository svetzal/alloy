---
title: Search and Retrieval
summary: The dimensions Alloy must retrieve intent by, with relational links authoritative and vector search optional.
layer: leaf
parent: data-model
tags: [data-model, search, retrieval]
---

# Search and Retrieval

Storing intent in the [[data-model]] is only half the job; Alloy must also be
able to retrieve it from many angles. Most retrieval starts from the
[[engineering-intent-record]] and the entities described in [[core-entities]].

## Retrieval dimensions

Alloy will need to retrieve intent by:

- Project.
- Code path or module.
- Product interaction.
- Design intent.
- Strategy.
- Capability.
- Threat.
- Evidence status.
- Active formation brief.
- Foundry trace ID.

## Relational versus vector

Vector search may be useful for semantic matching, but relational links should
remain authoritative for execution. Semantic matching can surface candidate
intent records; the relational graph decides what actually governs a run.

*Source: Product Brief §20 (Data Model Seed), Search and retrieval requirements.*
