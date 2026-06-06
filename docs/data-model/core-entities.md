---
title: Core Entities
summary: The product and intent-graph entities, from engineering intent records through formation briefs, prompt packs, and feedback.
layer: leaf
parent: data-model
tags: [data-model, entities, intent-graph]
---

# Core Entities

These are the product- and intent-graph entities of the [[data-model]]. They
record what is being built, the reasoning behind it, the evidence that backs
it, and the briefs and prompts derived from it. Several of these have
dedicated conceptual pages: the [[engineering-intent-record]], the
[[formation-brief]], the [[prompt-pack]], and [[evidence-and-gates]].

## engineering_intent_records

- id.
- project_id.
- title.
- capability.
- threat.
- expectation.
- strategy.
- evidence_summary.
- tradeoff.
- status.
- confidence.
- scope.
- created_at.
- updated_at.
- supersedes_id.
- version.

See [[engineering-intent-record]] for the conceptual treatment.

## intent_sources

- id.
- intent_record_id.
- source_type: human, code_observation, git_history, foundry_trace, epilogue,
  design_system, document, conversation.
- source_ref.
- excerpt or summary.
- confidence.
- created_at.

## intent_relationships

- id.
- from_intent_id.
- to_intent_id.
- relationship_type: supports, conflicts_with, supersedes, refines,
  depends_on, applies_to, constrains.
- notes.

## expectations

Expectations may deserve first-class treatment because multiple intent records
can depend on the same expectation.

- id.
- project_id.
- statement.
- confidence.
- time_horizon.
- source.
- review_trigger.

## strategies

Strategies may also deserve first-class treatment.

- id.
- name.
- local_definition.
- known_failure_modes.
- examples.
- exceptions.

## evidence_definitions

- id.
- intent_record_id.
- evidence_type.
- description.
- gate_name.
- command.
- required.
- status.
- review_policy.

See [[evidence-and-gates]] for how definitions relate to gates and observations.

## evidence_observations

- id.
- evidence_definition_id.
- observed_at.
- source_type: foundry_gate, manual_review, test_run, static_analysis,
  trace_analysis.
- result: pass, fail, unknown, waived.
- details.
- trace_id.

## code_observations

- id.
- project_id.
- observation_type.
- files.
- symbols.
- summary.
- raw_data.
- created_at.

## formation_briefs

- id.
- project_id.
- mission.
- source_product_refs.
- source_design_refs.
- source_engineering_intent_refs.
- protected_capabilities.
- threats_to_watch.
- strategies_to_prefer.
- forbidden_moves.
- evidence_plan.
- agent_formation.
- foundry_runtime.
- status.
- created_at.

See [[formation-brief]] for the conceptual treatment.

## prompt_packs

- id.
- formation_brief_id.
- phase.
- prompt_text.
- context_refs.
- model_hint.
- access_level.
- created_at.

See [[prompt-pack]] for the conceptual treatment.

## run_feedback

- id.
- formation_brief_id.
- foundry_trace_id.
- outcome.
- intent_satisfaction.
- contradictions.
- follow_up_questions.
- created_at.

*Source: Product Brief §20 (Data Model Seed), Core entities.*
