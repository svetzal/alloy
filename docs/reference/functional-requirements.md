---
title: Functional Requirements
summary: What users and Alloy can do, from intent records through Foundry integration and governance.
layer: leaf
parent: reference
tags: [requirements, functional, governance]
---

# Functional Requirements

This is the functional requirements seed for Alloy, grouped by capability area.
For the qualities these behaviours must satisfy, see
[[non-functional-requirements]]. Up to [[reference]].

## Intent records

Users can:

- create, edit, accept, deprecate, and supersede
  [[engineering-intent-record|engineering intent records]];
- scope records by project, module, technology, product area, or interaction;
- attach sources and evidence definitions;
- connect records through relationships;
- export selected records into repo-local projections.

## Assistant elicitation

Alloy's [[elicitation-assistants|elicitation assistants]] can:

- conduct guided interviews;
- draft intent records from user answers;
- ask follow-up questions when a field is vague;
- identify truisms and ask for context, evidence, and tradeoffs;
- distinguish principle, strategy, evidence, and preference.

## Codebase archaeology

Through [[codebase-archaeology]], Alloy can:

- inspect a repository read-only;
- identify structural signals;
- inspect existing documentation and gates;
- generate hypotheses with confidence and observations;
- require human validation before hypotheses become active constraints.

## Formation briefs

Alloy can:

- generate [[formation-brief|formation briefs]] from selected intent;
- include Epilogue references;
- include design intent references when available;
- produce Foundry runtime recommendations;
- compile prompt packs per Foundry phase;
- generate gate overlays or evidence plans.

## Foundry integration

Alloy can:

- emit or produce Foundry-compatible payloads;
- support dry-run-first execution;
- ingest Foundry traces;
- map Foundry gate results to evidence observations;
- report intent satisfaction after a run.

## Governance and review

Users can:

- see which intent records guided a run;
- see whether a record is human accepted or machine hypothesized;
- waive evidence with a reason;
- identify stale records;
- review contradictions.

*Source: Product Brief §25 (Functional Requirements Seed).*
