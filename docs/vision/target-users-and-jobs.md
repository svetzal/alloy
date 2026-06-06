---
title: Target Users and Jobs
summary: Alloy serves senior developers, engineering leaders, agent/workflow designers, and Epilogue Tracker product owners, each with distinct jobs around capturing and operationalizing engineering intent.
layer: leaf
parent: vision
tags: [vision, users, jobs]
---

# Target Users and Jobs

## Primary user: senior developer / technical lead

The senior developer knows why the code is shaped the way it is, but much of
that knowledge is tacit. They want agents to respect the team's architectural
boundaries, testing style, abstractions, technology choices, and scars from
previous systems.

Jobs:

- Capture engineering intent without spending a week writing architecture docs.
- Validate intent extracted from the codebase.
- Prevent agents from violating important boundaries.
- Make architectural preferences explicit enough for automation.
- Turn principles into evidence, not slogans.
- Keep intent current as the system changes.

## Secondary user: engineering manager / director

The engineering leader wants consistency across projects without imposing a
single monolithic architecture. They want to see what capabilities teams are
protecting, where agent work is drifting, and which
[[engineering-intent-record|intent records]] are actually being validated by
evidence.

Jobs:

- Understand codebase health through intent satisfaction rather than generic
  scorecards.
- See which teams are relying on undocumented engineering lore.
- Reduce risk from agentic execution.
- Encourage explicit engineering judgement without turning it into bureaucracy.

## Secondary user: agent/workflow designer

The agent workflow designer wants to build reusable [[alloy-and-foundry|Foundry]]
formations without hard-coding domain-specific judgement into every block or
prompt.

Jobs:

- Compile intent into [[formation-brief|formation briefs]].
- Select appropriate agent formations.
- Generate phase-specific [[prompt-pack|prompts]].
- Attach evidence and gate requirements.
- Feed trace outcomes back into the intent model.

## Secondary user: product owner using Epilogue Tracker

The product owner does not want engineering concerns polluting the product
backlog, but does want confidence that product work will be implemented in a
sustainable way. See [[alloy-and-epilogue-tracker]] for how the two systems
divide responsibility.

Jobs:

- Keep product intent focused on users and outcomes.
- Let engineering guidance live where tools can access it.
- Understand when engineering constraints affect product delivery.
- Avoid hiding plumbing work inside fake user stories.

---

Related: [[vision]] · [[product-goals]] · [[engineering-intent]] · [[intent-capture]]

*Source: Product Brief §6 (Target Users and Jobs).*
