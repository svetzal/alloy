---
title: Alloy Documentation
summary: Master map for the Alloy engineering-intent management layer and its Foundry runtime integration.
layer: home
tags: [alloy, home, map]
---

# Alloy Documentation

**Alloy** is a proposed engineering-intent management layer that sits *above*
[[alloy-and-foundry|Foundry]] and *beside* [[alloy-and-epilogue-tracker|Epilogue Tracker]].
Epilogue Tracker captures **product intent** (who the system helps, what goals
they have). Foundry executes **engineering work** as event-driven formations.
Alloy fills the missing layer between them: the explicit, structured expression
of **engineering intent** — the capabilities a team must preserve as the
software changes.

> Product intent says what people need the software to make possible.
> Engineering intent says what capabilities the codebase and team must retain
> as the software changes.

The guiding architectural principle across this wiki:

> **Alloy owns meaning. Foundry owns execution. [[formation-brief|Formation Briefs]] are the boundary.**

This documentation is split from two source documents — the **Alloy Product
Brief (Draft v0.2)** and the **Alloy / Foundry Runtime Integration Architecture
(Draft v0.1)** — and reorganized into a layered wiki. Each page below is an
overview that links down into detailed leaf pages.

---

## Map of the territory

### 1. [[vision|Vision & Positioning]]
Why Alloy exists, who it is for, and what it is *not*. The product thesis,
problem statement, positioning, users, goals, and narrative.

→ [[executive-summary]] ·
[[product-thesis]] ·
[[product-positioning]] ·
[[problem-statement]] ·
[[target-users-and-jobs|Target Users & Jobs]] ·
[[product-goals]] ·
[[non-goals]] ·
[[product-narrative]]

### 2. [[engineering-intent|Engineering Intent Model]]
The core object: the [[engineering-intent-record|Engineering Intent Record]]
and its six fields, its lifecycle, and worked examples.

→ [[engineering-intent-record|Engineering Intent Record]] ·
[[why-tradeoffs-matter|Why Tradeoffs Matter]] ·
[[record-lifecycle|Record Lifecycle]] ·
[[example-intent-records|Example Intent Records]]

### 3. [[intent-capture|Intent Capture]]
How Alloy elicits tacit engineering judgement instead of demanding blank-form
entry: assistant-led interviews and codebase archaeology.

→ [[elicitation-assistants|Elicitation Assistants]] ·
[[codebase-archaeology|Codebase Archaeology]] ·
[[archaeology-signals|Archaeology Signals]] ·
[[hypothesis-format|Hypothesis Format]]

### 4. [[ecosystem|Ecosystem & Boundaries]]
How Alloy relates to the systems around it and what each owns.

→ [[ownership-boundary|Ownership Boundary]] ·
[[alloy-and-epilogue-tracker|Alloy & Epilogue Tracker]] ·
[[alloy-and-foundry|Alloy & Foundry]] ·
[[design-intent-system|Design Intent System]]

### 5. [[runtime-artifacts|Runtime Artifacts]]
The compiled artifacts that form the stable seam between Alloy and Foundry.

→ [[formation-brief|Formation Brief]] ·
[[formation-brief-sections|Formation Brief Sections]] ·
[[formation-brief-lifecycle|Formation Brief Lifecycle]] ·
[[prompt-pack|Prompt Pack]] ·
[[prompt-pack-compilation|Prompt Pack Compilation]] ·
[[gate-overlay|Gate Overlay]] ·
[[evidence-plan|Evidence Plan]] ·
[[evidence-and-gates|Evidence & Gates]] ·
[[foundry-execution-request|Foundry Execution Request]] ·
[[foundry-run-result|Foundry Run Result]] ·
[[foundry-capability-manifest|Capability Manifest]]

### 6. [[agent-formations|Agent Formations]]
Choosing the social shape of agent work from the intent at stake.

→ [[formation-patterns|Formation Patterns]]

### 7. [[integration-architecture|Integration Architecture]]
The Phoenix/LiveView Alloy ↔ Rust Foundry boundary in depth.

→ [[architectural-decision|Architectural Decision]] ·
[[boundary-principles|Boundary Principles]] ·
[[system-roles|System Roles]] ·
[[runtime-topology|Runtime Topology]] ·
[[integration-modes|Integration Modes]] ·
[[idempotency-and-correlation|Idempotency & Correlation]] ·
[[security-and-authority|Security & Authority]] ·
[[failure-handling|Failure Handling]] ·
[[observability-and-audit|Observability & Audit]] ·
[[versioning-and-compatibility|Versioning & Compatibility]]

### 8. [[trace-feedback|Trace Feedback & Learning]]
Turning Foundry traces back into intent updates.

→ [[learning-loop|Learning Loop]] ·
[[drift-detection|Drift Detection]] ·
[[contradiction-detection|Contradiction Detection]]

### 9. [[data-model|Data Model]]
The PostgreSQL-backed entities behind the intent graph and the runtime.

→ [[core-entities|Core Entities]] ·
[[runtime-entities|Runtime Entities]] ·
[[search-and-retrieval|Search & Retrieval]]

### 10. [[interfaces|Interfaces]]
How humans and machines drive Alloy.

→ [[cli|CLI]] · [[api|API]]

### 11. [[workflows|Workflows]]
The end-to-end journeys Alloy supports.

→ [[workflow-capture-from-conversation|Capture from Conversation]] ·
[[workflow-extract-from-codebase|Extract from Codebase]] ·
[[workflow-implement-epilogue-interaction|Implement Epilogue Interaction]] ·
[[workflow-detect-resolve-drift|Detect & Resolve Drift]] ·
[[workflow-create-foundry-formation|Create Foundry Formation]] ·
[[end-to-end-flows|End-to-End Flows]]

### 12. [[delivery|Delivery Plan]]
From MVP through the later roadmap and phased integration.

→ [[mvp|MVP]] ·
[[roadmap|Roadmap]] ·
[[phased-integration-plan|Phased Integration Plan]] ·
[[specification-backlog|Specification Backlog]] ·
[[immediate-next-steps|Immediate Next Steps]]

### 13. [[reference|Reference]]
Requirements, risks, open questions, sources, and a glossary.

→ [[functional-requirements|Functional Requirements]] ·
[[non-functional-requirements|Non-Functional Requirements]] ·
[[risks|Risks & Countermeasures]] ·
[[open-questions|Open Questions]] ·
[[source-grounding|Source Grounding]] ·
[[glossary|Glossary]]

---

## How to read this wiki

- **Home → Section → Leaf.** This page is the top layer. Each numbered link is a
  *section overview*. Each section overview summarizes and links to *leaf pages*
  that hold the detail.
- **Wikilinks.** Pages reference each other with `[[double-bracket]]` links.
  Filenames are globally unique, so `[[slug]]` resolves regardless of folder.
  Follow them laterally to related ideas.
- **Provenance.** Each leaf page notes which source document and section it was
  split from, so the original briefs remain traceable.

---

*Source documents: Alloy Product Brief (Draft v0.2) and Alloy / Foundry Runtime
Integration Architecture (Draft v0.1), Mojility / Stacey Vetzal, 2026-06-06.*
