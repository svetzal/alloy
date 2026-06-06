---
title: Prompt Pack Compilation
summary: Why Alloy compiles phase-specific prompts and what each phase view (Assessment, Triage, Planning, Execution, Retry, Summarization, Review) tells its agent.
layer: leaf
parent: runtime-artifacts
tags: [prompt-pack, compilation, phases, intent]
---

# Prompt Pack Compilation

Prompt compilation is one of Alloy's central responsibilities.

## Why compilation exists

Foundry has agent-driven phases such as assessment, triage, planning, execution, retry, and summarization. Without Alloy, these phases may depend on general prompts or one-off strategic prompts.

Alloy should replace those one-off prompts with compiled, phase-specific [[prompt-pack]]s generated from structured intent. Alloy should not simply concatenate intent records into one giant prompt — different Foundry phases need different intent views, and the same [[formation-brief]] should produce different guidance for each phase.

## Phase-specific views

The same brief is read through a different lens for each phase. Each view below states the phase's purpose and what its agent should be told.

### Assessment

**Purpose:** decide where work is needed — compare the codebase against relevant intent.

The assessment agent should be told:

- The product/design objective.
- Which capabilities matter and which relevant engineering intent records apply.
- Which threats to look for.
- Which code areas are likely relevant (codebase observations).
- Which observations would count as evidence.
- To avoid generic best-practice critique unless it threatens a named capability.

Assessment principle:

> Find the highest-value discrepancy between intended product/design outcome, protected engineering capabilities, current code structure, and required evidence.

### Triage

**Purpose:** decide whether an assessment finding is worth acting on.

The triage agent should be told to accept a finding only when:

- A named capability is threatened.
- The expectation behind the capability is still plausible.
- The proposed work can produce observable evidence.
- The finding is not cosmetic busy-work or generic style preference.
- The tradeoff is acceptable in this context.

A finding should be escalated if it contradicts accepted intent rather than acted on blindly.

### Planning

**Purpose:** produce a minimal, testable correction plan.

The planning agent should be told:

- Which files and boundaries are in scope (naming exact files and functions where possible).
- Which strategies to prefer and which suspicious moves to avoid.
- To connect each step to an intent record and include evidence-gathering steps.
- Which evidence must exist after execution and which gates must pass.
- To prefer small, reversible changes.
- To identify ambiguity that should stop the run.

### Execution

**Purpose:** apply the plan with direct working instructions.

The execution agent should be told:

- The exact objective and the allowed scope (change only the declared scope).
- The protected boundaries and capabilities to preserve.
- The expected evidence to leave behind.
- The things it must not weaken — avoid known drift patterns, keep gates passing, do not weaken tests.

### Retry

**Purpose:** narrow failure correction — fix failed evidence.

The retry agent should be told:

- Which gate failed and what was attempted.
- What evidence is still missing.
- To focus only on failed gates or evidence and not broaden the change.
- To avoid changing product behaviour unless necessary.
- To stop if the failure indicates contradicted intent rather than an implementation error.

### Summarization

**Purpose:** report what happened in intent language.

The summarization agent should report:

- Which capabilities were preserved or improved.
- Which threats were reduced or introduced.
- Which evidence was collected.
- Which gates passed or failed.
- Which intent records were contradicted.
- Which follow-up questions should be asked.

### Review and intent feedback

Beyond the core phases, a pack may include `review.md` and `intent_feedback.md` views, which carry results back into the living intent graph rather than driving the run forward.

## Related

- [[prompt-pack]] — the compiled bundle these views live in
- [[agent-formations]] — how phases are assembled into a run
- [[evidence-and-gates]] — the evidence and gate expectations each phase references
- [[runtime-artifacts]] — section overview

*Source: Product Brief §16; Integration Architecture §14.*
