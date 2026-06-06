---
title: The Ownership Boundary
summary: The central principle that Alloy owns meaning, Foundry owns execution, and Formation Briefs are the boundary between them.
layer: leaf
parent: ecosystem
tags: [boundary, architecture, formation-brief]
---

# The Ownership Boundary

The ecosystem (see [[ecosystem]]) rests on one architectural principle:

> Alloy owns meaning. Foundry owns execution. Formation Briefs are the
> boundary.

## Runtime architecture summary

The working architecture is a split system:

```text
Alloy
  Phoenix / LiveView / PostgreSQL
  User-facing engineering intent administration
  Intent graph, reviews, assistants, archaeology, briefs, prompt packs, evidence plans

        ↓ compiles and publishes

Formation Briefs, Prompt Packs, Gate Overlays, Evidence Plans
  Immutable runtime artifacts
  Versioned, reviewable, digestable

        ↓ consumed by

Foundry
  Rust daemon and CLI over gRPC
  Event-driven execution engine
  Task blocks, throttle, gates, retries, traces, side effects

        ↑ reports

Run Results, Trace Summaries, Evidence Observations
  Used by Alloy to update intent satisfaction, detect drift, and ask better questions
```

## Why the boundary matters

Alloy's ontology will evolve quickly. Capabilities, threats, expectations,
strategies, evidence, tradeoffs, design-intent relationships, Epilogue
references, assistant behaviours, and prompt compiler rules should be able
to change without forcing Foundry recompilation.

To make that possible, Foundry should receive a narrow execution request
containing a brief ID, brief digest, entry event, throttle, project,
repository context, and payload. Foundry blocks that need richer context
may resolve the compiled [[formation-brief]] locally or through an
Alloy-aware provider, but Foundry should not need to understand Alloy's
canonical intent graph.

This is the boundary made concrete. As the [[integration-architecture]]
puts it, the Formation Brief should be narrow enough that Foundry does not
need Alloy's entire ontology, yet rich enough to shape assessment,
planning, execution, verification, and summarization. Foundry should not
need to know what a `Capability`, `Threat`, `Expectation`, `Strategy`, or
`Tradeoff` means in Alloy's canonical model — Alloy translates its model
into Foundry-facing shapes such as agent context sections, prompt pack
references, gate overlay references, runtime controls, evidence plan
references, and reporting instructions.

## No orchestration leakage

Alloy should also avoid becoming a second workflow orchestrator. It should
not sequence Foundry's internal task blocks. Instead of saying "run Check
Charter, then Resolve Gates, then Preflight," Alloy says: emit an entry
event for this project using this throttle, this payload, and this
Formation Brief. Foundry decides which task blocks fire — its
event/block/throttle model remains the execution authority.

The first integration mode should be projection-based: Alloy generates
`.alloy/` artifacts and a Foundry-compatible prompt or strategic-prompt
package. Later modes can add a CLI bridge, runner pull model, native brief
references, streaming traces, and eventually configurable formation
composition once Foundry extracts its composition layer. See
[[alloy-and-foundry]] for how this fits Foundry's documented direction.

*Source: Product Brief §14 (Runtime architecture summary); Integration Architecture §4.3–4.5.*
