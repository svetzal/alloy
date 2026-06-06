---
title: Later Roadmap
summary: The product roadmap beyond the MVP, Phases 1–6, from intent capture to multi-intent orchestration.
layer: leaf
parent: delivery
tags: [roadmap, phases, planning]
---

# Later Roadmap

The product roadmap that follows the [[mvp]] expands Alloy's capability in six
phases. It runs in parallel with the Foundry [[phased-integration-plan]].

## Phase 1: Intent capture and projection

- Structured records.
- Assistant interviews.
- Markdown/YAML export.
- Basic source tracking.
- Local repo projections.

## Phase 2: Codebase archaeology

See [[codebase-archaeology]].

- Static structural analysis.
- Import graph inspection.
- Test organization inspection.
- Gate inspection.
- Docs and commit message extraction.
- Hypothesis review workflow.

## Phase 3: Foundry formation briefs

- [[formation-brief|Formation brief]] model.
- [[prompt-pack|Prompt pack]] compiler.
- [[gate-overlay|Gate overlay]] compiler.
- Existing Foundry strategic prompt integration.
- Dry-run-first workflow.

## Phase 4: Native Foundry integration

Possible Foundry additions:

- `formation_brief_created` event.
- `intent_context_resolved` event.
- `prompt_pack_compiled` event.
- `evidence_plan_created` event.
- `intent_feedback_recorded` event.
- Task blocks for resolving Alloy context.

The goal is not to overload Foundry with semantic knowledge. Events should
mostly carry IDs and references. Alloy remains the semantic system.

## Phase 5: Trace-to-intent learning

See [[trace-feedback]].

- Automatic trace ingestion.
- Evidence observation updates.
- Drift detection.
- Contradiction detection.
- Human review queues.
- Confidence updates.

## Phase 6: Multi-intent orchestration

- Combine Epilogue product intent, design intent, and Alloy engineering intent.
- Resolve conflicts.
- Select agent formations based on intent risk.
- Generate richer runtime briefs.

Up: [[delivery]]

*Source: Product Brief §24 (Later Roadmap).*
