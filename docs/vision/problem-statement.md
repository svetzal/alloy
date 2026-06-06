---
title: Problem Statement
summary: Foundry accumulates hidden engineering judgement inside task blocks and prompts; Alloy externalizes that judgement so developers can express, validate, evolve, and operationalize it.
layer: leaf
parent: vision
tags: [vision, problem, foundry]
---

# Problem Statement

[[alloy-and-foundry|Foundry]] already automates real engineering workflows, but
the current direction reveals an abstraction gap.

The hard-coded pieces are not merely mechanical plumbing. They contain embedded
engineering judgement:

- Which blocks should participate in a run.
- Which prompt should drive assessment.
- What "good" means for a codebase.
- When an agent should continue or stop.
- Which gates matter for the current work.
- Which principles are being protected.
- Which risks are worth acting on.
- Which changes count as busy-work.

Foundry's current strategic loop lets a user provide a `strategic_prompt`, but
that makes the user manually encode intent at runtime. The prompt is powerful,
but too thin. It cannot reliably carry a team-wide, codebase-specific,
versioned model of engineering intent.

The danger is that Foundry becomes increasingly capable while also accumulating
hidden policy inside task blocks, prompt strings, and workflow-specific code.
That would make Foundry harder to adapt to new project types, agent formations,
programming ecosystems, and product/design contexts.

Alloy addresses this by externalizing the engineering judgement that should not
belong inside Foundry's runtime.

The product problem is not "how do we document architecture better?" The
problem is:

> How do we help developers express, validate, evolve, and operationalize the
> engineering intent that should guide autonomous software work?

---

Related: [[vision]] · [[product-thesis]] · [[engineering-intent]] · [[alloy-and-foundry]]

*Source: Product Brief §5 (Problem Statement).*
