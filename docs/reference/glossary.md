---
title: Glossary
summary: Concise definitions of Alloy's key terms, each linked to its home page.
layer: leaf
parent: reference
tags: [glossary, terminology, definitions]
---

# Glossary

Key terms used across the Alloy wiki, defined in a sentence or two and linked to
where each is treated in full. Up to [[reference]].

## A

**Agent Formation** — A configured arrangement of agent roles (such as builder,
red-team, or simplicity reviewer) and the prompts and gates that guide them
through a Foundry phase. See [[agent-formations]].

**Alloy** — The semantic compiler and control plane that captures engineering
intent and compiles it into runtime work for Foundry, sitting alongside Epilogue
Tracker and Foundry rather than replacing either. See [[index]].

## C

**Capability** — One of the six fields of an engineering intent record: the
engineering capability the intent is about. See [[engineering-intent-record]].

**Capability Manifest** — Foundry's declaration of what task blocks, events, and
formations it can run, which Alloy reads to know what runtime work it can target.
See [[foundry-capability-manifest]].

**Codebase Archaeology** — Alloy's read-only inspection of a repository to
surface structural signals and propose hypotheses about its implicit engineering
intent, always pending human validation. See [[codebase-archaeology]].

**Contradiction** — A conflict between two intent records, or between intent and
observed behaviour, that Alloy surfaces for review. See
[[contradiction-detection]].

## D

**Design Intent** — Intent about design and interaction concerns, referenced by
formation briefs when available and distinct from product intent (Epilogue) and
engineering intent (Alloy). See [[design-intent-system]].

**Drift** — The gradual divergence of a codebase or its runtime behaviour from
the intent that was supposed to govern it, which Alloy detects to keep records
honest. See [[drift-detection]].

## E

**Elicitation Assistant** — The conversational Alloy capability that conducts
guided interviews, drafts intent records from answers, and probes vague fields
for context, evidence, and tradeoffs. See [[elicitation-assistants]].

**Engineering Intent** — The reasoning behind engineering decisions — the
capabilities, threats, expectations, strategies, evidence, and tradeoffs — that
Alloy makes explicit and durable. See [[engineering-intent]].

**Engineering Intent Record** — The canonical unit of engineering intent in
Alloy, built from six fields (capability, threat, expectation, strategy,
evidence, tradeoff) and moving through a lifecycle from hypothesized to accepted,
deprecated, or superseded. See [[engineering-intent-record]].

**Epilogue Tracker** — The companion product that keeps user goals visible from
discovery through delivery, maintaining a living model of users, goals, and
interactions; Alloy treats it as the source of product intent. See
[[alloy-and-epilogue-tracker]].

**Evidence** — One of the six fields of an engineering intent record: how we
would know whether the intent is being honoured. See
[[engineering-intent-record]].

**Evidence Plan** — A runtime artifact compiled from intent that tells Foundry
what evidence to gather and check during a run, as an alternative or complement
to a gate overlay. See [[evidence-plan]].

**Expectation** — One of the six fields of an engineering intent record: what we
expect to be true if the intent holds. See [[engineering-intent-record]].

## F

**Formation Brief** — The immutable, compiled package Alloy generates from
selected intent, bundling references, Foundry recommendations, prompt packs, and
gate overlays or evidence plans for a run. See [[formation-brief]].

**Foundry** — The event-driven workflow engine for engineering automation that
replaces imperative shell scripts with composable task blocks connected by
events, running as the `foundryd` daemon with the `foundry` CLI; Alloy's runtime.
See [[alloy-and-foundry]].

**Foundry Capability Manifest** — See *Capability Manifest*.

**Foundry Execution Request** — The payload Alloy emits to ask Foundry to run a
formation, carrying references rather than large semantic payloads. See
[[foundry-execution-request]].

**Foundry Run Result** — The outcome Foundry returns after executing a request,
including gate results and trace references that Alloy maps back to evidence. See
[[foundry-run-result]].

**Functional Core / Imperative Shell** — The architectural pattern, echoed in
Foundry's replacement of imperative shell scripts with composable blocks, of
keeping pure decision logic in a functional core surrounded by a thin shell that
performs side effects.

## G

**Gate** — A Foundry checkpoint (preflight or verification) that must pass for a
run to proceed or be considered successful; Foundry already provides gate
orchestration with bounded retry. See [[evidence-and-gates]].

**Gate Overlay** — A runtime artifact compiled from intent that adjusts or adds
to Foundry's gates for a particular run. See [[gate-overlay]].

**Gateway Abstraction** — A boundary type that isolates an external system
behind a stable interface, used in Alloy to keep the Foundry runtime separable
from the semantic control plane. See [[boundary-principles]].

## H

**Hypothesis** — A machine-proposed intent record carrying confidence and
supporting observations, which must be human-accepted before it becomes an active
runtime constraint. See [[hypothesis-format]].

## P

**Prompt Pack** — The set of prompts Alloy compiles per Foundry phase from a
formation brief, steering the agents that do the work. See [[prompt-pack]].

## R

**Runner / Bridge** — The process or component that carries requests between
Phoenix/LiveView Alloy and Rust Foundry and relays results back; its form
(separate process, Foundry subcommand, or Alloy CLI) is still open. See
[[runtime-topology]].

## S

**Strategy** — One of the six fields of an engineering intent record: the
approach chosen to meet the expectation. See [[engineering-intent-record]].

## T

**Task Block** — A Foundry building block that declares which events it sinks on,
what work it performs, and which events it emits; workflows emerge from these
sink/emit relationships rather than being declared as first-class objects. See
[[alloy-and-foundry]].

**Threat** — One of the six fields of an engineering intent record: what the
intent is defending against. See [[engineering-intent-record]].

**Throttle** — The Foundry control that governs how far each event ripples
through the system, bounding the depth of automated work. See
[[alloy-and-foundry]].

**Trace** — A Foundry run's record of events and outcomes that Alloy ingests and
summarizes to assess whether intent was satisfied. See [[trace-feedback]].

**Tradeoff** — One of the six fields of an engineering intent record: what is
given up by following the strategy, and when it would be too much. See
[[engineering-intent-record]].

*Source: Product Brief §§2, 25; Integration Architecture §2. Foundry-native terms (throttle, task block, gate, trace) per Foundry public documentation [F1]–[F5].*
