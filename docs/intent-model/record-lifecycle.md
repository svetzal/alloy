---
title: Record Lifecycle
summary: Records move through states from Hypothesized to Superseded because extracted intent is often a hypothesis, not a fact.
layer: leaf
parent: engineering-intent
tags: [intent, lifecycle, states]
---

# Record Lifecycle

Alloy records should move through states. The state matters because extracted
intent is often a hypothesis, not a fact.

## Suggested states

### Hypothesized

Created by codebase archaeology, conversation parsing, or trace analysis. The
system believes this intent may exist, but a human has not confirmed it.

### Proposed

A human or assistant has drafted the record and it is ready for review.

### Accepted

A qualified human has confirmed the record should guide work.

### Active

The record is accepted and currently used in formation briefs, prompt packs, or
gate/evidence generation.

### Deprecated

The record reflects an older intent that is no longer generally applicable, but
its history remains useful.

### Contradicted

Evidence from code, traces, or human review shows that the record is no longer
true, was too broad, or conflicts with current product/design/engineering
reality.

### Superseded

The record has been replaced by a newer record with clearer scope, better
evidence, or a changed strategy.

## Lifecycle principles

- Codebase extraction should default to **Hypothesized**, not **Accepted**.
- Human-entered records may start as **Proposed**.
- Only **Accepted** or **Active** records should guide Foundry execution by
  default.
- **Hypothesized** records may be used as prompts for human clarification, not
  as hard constraints.
- Trace feedback can recommend state transitions, but should not silently
  perform major transitions without policy.

## Related

- [[codebase-archaeology]] — extraction from existing code defaults records to
  Hypothesized.
- [[formation-brief]] — only Accepted or Active records are compiled into work
  guidance by default.

## Up

- [[engineering-intent]] — section overview.

*Source: Product Brief §10 (Record Lifecycle).*
