---
title: Prompt Pack
summary: A bundle of phase-specific agent instructions compiled from structured intent, traceable to its source and re-digested when edited.
layer: leaf
parent: runtime-artifacts
tags: [prompt-pack, compilation, traceability, runtime]
---

# Prompt Pack

A Prompt Pack contains phase-specific instructions derived from the [[formation-brief]]. Each phase of a Foundry run gets its own compiled instructions rather than a single general prompt or a hand-written one-off string buried inside a task block.

The important point: **prompts are compiled views of structured intent, not hand-written one-off strings hidden inside task blocks.** For the reasoning behind compilation and the detail of each phase view, see [[prompt-pack-compilation]].

## Prompt files

A Prompt Pack may contain a prompt file per phase:

```text
assessment.md
triage.md
planning.md
execution.md
review.md
retry.md
summarization.md
intent_feedback.md
```

## Traceability

Each prompt should be traceable back to:

- Formation Brief ID.
- Source intent records.
- Product/design references.
- Compiler version.
- Prompt template version.
- Human edits, if any.

This traceability is what lets a reviewer answer "why does the agent say this?" by following the prompt back to the intent it was compiled from.

## Human-editable packs

Prompt packs should be inspectable and editable before execution, but edits should be recorded. **A human-edited prompt pack is a new compiled artifact with its own digest.**

This preserves the immutability guarantee: once a pack drives a run, its exact contents are pinned and identified by digest, so an edit never silently changes what an earlier run was told to do.

## Related

- [[prompt-pack-compilation]] — why compilation exists and the per-phase views
- [[formation-brief]] — the artifact a pack is compiled from
- [[runtime-artifacts]] — section overview

*Source: Integration Architecture §7.2, §14.3–14.4.*
