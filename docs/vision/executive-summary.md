---
title: Executive Summary
summary: Alloy is an engineering intent management layer above Foundry and beside Epilogue Tracker that compiles tacit judgement into runtime guidance for autonomous work.
layer: leaf
parent: vision
tags: [vision, summary, overview]
---

# Executive Summary

Alloy is a proposed engineering intent management layer that sits above
[[alloy-and-foundry|Foundry]] and beside [[alloy-and-epilogue-tracker|Epilogue Tracker]].
Epilogue Tracker captures product intent: who the system helps, what goals those
actors have, and what interactions support those goals. Foundry executes
engineering work as event-driven formations of task blocks, gates, agents,
traces, and throttle-controlled propagation. Alloy fills the missing layer
between them: the explicit, structured expression of [[engineering-intent]].

Alloy is expected to be a user-facing administration system, closer in product
shape to Epilogue Tracker than to Foundry. The working implementation assumption
is Phoenix/LiveView backed by PostgreSQL: a responsive web application for
capturing, reviewing, explaining, and refining a living model. Foundry should
remain the Rust-based execution substrate. The seam between them should be
compiled runtime artifacts, especially immutable [[formation-brief|Formation Briefs]],
rather than direct orchestration or shared internal models.

The central thesis is simple:

> Product intent says what people need the software to make possible.
> Engineering intent says what capabilities the codebase and team must retain
> as the software changes.

Alloy models engineering intent as records of capabilities, threats,
expectations, strategies, evidence, and tradeoffs. These records are not meant
to become another backlog. They are runtime guidance for autonomous engineering
work. Alloy should turn tacit engineering judgement into a form that agents,
Foundry formations, gates, prompt packs, and humans can all use.

The near-term product opportunity is to make Foundry less dependent on
hard-coded workflows and one-off strategic prompts. Foundry should remain the
execution substrate: events, task blocks, throttle, traceability, and gate
execution. Alloy should become the control plane that decides what engineering
intent applies to a run, compiles that intent into a [[formation-brief|formation brief]],
shapes the agent formation, generates or selects prompt context, proposes
evidence, and feeds the results of Foundry traces back into the intent model.

The product should not ask developers to fill in blank architecture forms from
scratch. Developers often recognize engineering intent when it is shown to
them, but struggle to express it cold because much of it is tacit. Alloy should
therefore include [[intent-capture|assistant-driven elicitation and codebase archaeology]].
It should inspect code, history, conventions, gates, tests, and prior decisions;
generate hypotheses about the engineering intent already present; and ask the
developer targeted questions such as "why is this boundary here?", "what would
make you reject this PR?", or "what failure from a previous system are you
trying not to repeat?"

The first useful version of Alloy should produce three concrete artifacts:

1. **[[engineering-intent-record|Engineering intent records]]** that capture the
   capabilities the team is trying to preserve, the threats that erode them, the
   expectations that make them matter, the strategies used to protect them, the
   evidence required to know whether they are working, and the tradeoffs
   involved.
2. **[[formation-brief|Formation briefs]]** that compile relevant product,
   design, and engineering intent into a runtime package Foundry can execute.
3. **[[prompt-pack|Prompt and evidence packs]]** that translate intent into
   phase-specific agent guidance and gate/evidence requirements.

Alloy becomes valuable when a user can say something like:

> "Pick the highest-priority Epilogue interaction and implement it, while
> preserving our Phoenix LiveView boundary, keeping business rules in the
> functional core, using gateway abstractions for external services, and
> proving the result with the right gates."

The important part is that the user should not need to write that entire prompt
manually. Alloy should know it.

---

Related: [[vision]] · [[product-thesis]] · [[product-positioning]] · [[ecosystem]]

*Source: Product Brief §1 (Executive Summary).*
