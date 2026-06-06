---
title: Source Grounding
summary: How Alloy is grounded in the public Foundry and Epilogue Tracker documentation, with verbatim citations.
layer: leaf
parent: reference
tags: [grounding, foundry, epilogue, citations]
---

# Source Grounding

Alloy's design is grounded in the current public descriptions of Foundry and
Epilogue Tracker. This page consolidates the grounding from both the Product
Brief and the Integration Architecture and preserves their source-note
citations verbatim. Up to [[reference]].

## Foundry reality

Foundry is described as an event-driven workflow engine for engineering
automation. It replaces imperative shell scripts with composable task blocks
connected by events, with throttle controlling how far each event ripples
through the system. It runs as a daemon, `foundryd`, with a CLI controller,
`foundry`, communicating over gRPC. Any emitter can fire an event and trigger
the same downstream workflow. [F1]

Foundry currently has two Rust-defined layers: an event library and a block
library. The event library provides the vocabulary of immutable facts. The
block library contains reusable task blocks that declare what events they sink
on, what work they perform, and what events they emit. Foundry's workflows are
not declared as first-class objects; they emerge from event sink/emit
relationships and block self-filtering based on payload fields. [F2]

Foundry's documented direction is especially relevant to Alloy: events and
blocks are expected to remain Rust-defined because they benefit from type safety
and compile-time guarantees, while the composition layer is intended to be
extracted so that teams can declare block participation and event flow through
configuration rather than recompilation. [F3]

Foundry already has gate orchestration, preflight gates, verification gates,
bounded retry, project iteration, maintenance, vulnerability remediation,
validation, and strategic iteration. The documented formations include the full
nightly run, iterate formation, prompt formation, strategic iterate formation,
maintain formation, vulnerability remediation formation, scan formation, and
validation formation. The standard iterate workflow resolves gates, verifies the
project is already in a passing state, validates that intent documentation
exists, assesses the codebase, triages the finding, creates a concrete plan,
executes the plan, verifies gates, and retries on gate failure. [F4]

Strategic iteration already starts to point toward Alloy. It wraps the iterate
formation with an outer AI loop that identifies areas for improvement, enters
inner iterations, and asks whether further work is warranted. A user can steer
this loop with a `strategic_prompt`, and Foundry uses that prompt during both
assessment and continuation decisions. Foundry's charter emphasizes events over
orchestration, composable task blocks, throttle-controlled depth, observability,
and correctness through Rust types, and explicitly scopes Foundry to engineering
workflow automation rather than a general-purpose workflow engine or CI/CD
replacement. [F5]

For how Alloy sits relative to this runtime, see [[alloy-and-foundry]].

## Epilogue Tracker reality

Epilogue Tracker is positioned around keeping user goals visible from discovery
through delivery. It helps teams answer who a task helps, what goal it supports,
and how it helps that person get there. [E1]

Epilogue Tracker maintains a living model of users, their goals, and the work
that connects them. It maps users, goals, and interactions; updates the model
from conversations and meetings using AI; and catches missing goals, work that
lacks user support, and broken connections. [E2]

The Epilogue Tracker site makes an important architectural claim for Alloy: the
backlog should stay focused on people rather than plumbing, while technology
decisions, architecture, coding standards, and constraints live as guidance
inside the system where tools can access them. [E3]

For how Alloy complements Epilogue Tracker, see [[alloy-and-epilogue-tracker]].

## Source notes (Product Brief)

- [F1] Foundry introduction, https://vetzal.com/foundry/print.html
- [F2] Foundry current layers and emergent workflows,
  https://vetzal.com/foundry/print.html
- [F3] Foundry future direction for configurable composition,
  https://vetzal.com/foundry/print.html
- [F4] Foundry iterate workflow and gate orchestration,
  https://vetzal.com/foundry/print.html
- [F5] Foundry strategic iteration and custom prompt,
  https://vetzal.com/foundry/print.html
- [E1] Epilogue Tracker landing page, https://epiloguetracker.ca/
- [E2] Epilogue Tracker product model description,
  https://epiloguetracker.ca/
- [E3] Epilogue Tracker technology guidance statement,
  https://epiloguetracker.ca/

## Source notes (Integration Architecture)

- [F1] Foundry introduction, https://vetzal.com/foundry/
- [F2] Foundry current layers and emergent workflows, https://vetzal.com/foundry/
- [F3] Foundry future direction for configurable composition, https://vetzal.com/foundry/
- [F4] Foundry workflow formations, https://vetzal.com/foundry/guide/workflow-formations.html
- [F5] Foundry charter, https://vetzal.com/foundry/charter.html
- [E1] Epilogue Tracker landing page, https://epiloguetracker.ca/
- [E2] Epilogue Tracker model description, https://epiloguetracker.ca/
- [E3] Epilogue Tracker technology guidance statement, https://epiloguetracker.ca/

*Source: Product Brief §2 (Source Grounding); Integration Architecture §2 (Source Grounding).*
