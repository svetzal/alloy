---
title: Data Model
summary: A PostgreSQL-backed model combining structured tables with JSONB for flexible extension, split between product-graph and runtime entities.
layer: section
parent: index
tags: [data-model, postgresql, schema]
---

# Data Model

Alloy is backed by a likely PostgreSQL data model that pairs structured tables
with JSONB columns for flexible extension. Relational links remain
authoritative for execution, while vector search may help with semantic
matching of intent.

The model divides into two groups:

- **Product-graph entities** capture the durable intent graph — what is being
  built, why, what protects it, and what evidence backs it. See
  [[core-entities]].
- **Runtime entities** capture the integration and execution layer — compiled
  briefs, run requests, results, and imported traces. See
  [[runtime-entities]].

## Retrieving intent

Beyond storage, Alloy must retrieve intent along many dimensions — project,
code path, capability, threat, evidence status, and more. See
[[search-and-retrieval]] for the full set of retrieval requirements and how
relational links and optional vector search fit together.

*Source: Product Brief §20 (Data Model Seed).*
