# Alloy — Product Charter

> The same five-field structure as an Epilogue Tracker / `et` charter
> (`mission`, `target_audience`, `problem_space`, `differentiators`,
> `out_of_scope`), which Alloy mirrors natively (one charter per project).
> This file is a readable projection of the charter; the canonical store is
> Alloy's per-project charter, edited via `alloy charter set`.

## Mission

Make a team's engineering judgement explicit enough that agents can act on it.
Alloy captures the capabilities a codebase must preserve as it changes — the
threats that erode them, the expectations that make them matter, the strategies
that protect them, the evidence that proves them, and the tradeoffs they carry —
and compiles that judgement into runtime guidance for autonomous engineering
work.

## Target Audience

Teams using agents to build and evolve software. Primary user is the **senior
developer / technical lead** who knows why the code is shaped the way it is but
holds most of it tacitly. Secondary users: **engineering managers / directors**
wanting consistency and visibility into what teams are protecting without
imposing one architecture; **agent / workflow designers** building reusable
Foundry formations without hard-coding domain judgement; and **product owners
using Epilogue Tracker** who want product work implemented sustainably without
engineering concerns polluting the backlog. (These roles become the actors of
the intent model.)

## Problem Space

Autonomous delivery needs more than product requirements and an execution
engine. Foundry runs engineering work as event-driven formations, but
accumulates hidden engineering judgement inside task blocks, prompt strings, and
workflow-specific code — which blocks run, what "good" means, when an agent
stops, which gates and principles matter. Its `strategic_prompt` escape hatch
forces users to encode intent by hand at runtime and is too thin to carry a
team-wide, codebase-specific, versioned model. The underlying problem is not
"how do we document architecture better?" but **how do we help developers
express, validate, evolve, and operationalize the engineering intent that should
guide autonomous work** — most of which is tacit and easier to recognize than to
write cold.

## Differentiators

Alloy owns **engineering intent** specifically — distinct from Epilogue
Tracker's product intent, a design system's experience intent, and Foundry's
execution. It models intent as structured six-field records (capability, threat,
expectation, strategy, evidence, tradeoff) that are actionable rather than
slogans like "keep code simple." It elicits tacit judgement through
assistant-led interviews and codebase archaeology instead of demanding
blank-form entry, generating hypotheses a human confirms or rejects. It compiles
relevant intent into immutable **formation briefs** plus prompt and evidence
packs that Foundry executes — *Alloy owns meaning, Foundry owns execution,
formation briefs are the boundary* — and closes the loop by feeding Foundry
traces back into the intent model. Principles always carry tradeoffs; inferences
always require human validation.

## Out of Scope

Alloy is **not** a replacement for Foundry (the engineering workflow runtime),
Epilogue Tracker (the product intent system), or a design intent system. It is
not a general-purpose project-management or ticketing tool — not "Jira with
engineering-sounding nouns" — and not a static ADR repository where records are
written once and forgotten. It does not treat principles as commandments without
tradeoffs, does not auto-accept codebase inferences without human validation, and
does not force every team into the same architecture. It does not make a
repo-local `CHARTER.md` the canonical store; repo-local documents are projections
of the intent graph, not its source of truth.
