---
title: Product Thesis
summary: Autonomous software delivery needs explicit engineering intent — the properties developers preserve as a system evolves — making Alloy a control plane for engineering judgement.
layer: leaf
parent: vision
tags: [vision, thesis, engineering-intent]
---

# Product Thesis

Alloy exists because autonomous software delivery needs more than product
requirements and agent execution. It needs explicit [[engineering-intent]].

[[alloy-and-epilogue-tracker|Epilogue Tracker]] can tell us which human outcome
a piece of work serves. [[alloy-and-foundry|Foundry]] can run engineering work
through observable, event-driven formations. But neither of those alone fully
captures the developer's intent: the properties developers are trying to
preserve as the system evolves.

Engineering intent is not the same thing as requirements management.
Requirements management usually asks, "what must the system do?" Engineering
intent asks, "what must remain true about how the system can be changed,
understood, tested, operated, and evolved?"

That makes Alloy a control plane for engineering judgement.

Alloy should answer questions such as:

- What capabilities are we trying to preserve in this codebase?
- What threats erode those capabilities?
- What future changes or pressures make those threats important?
- What strategies do we prefer because they protect those capabilities?
- What evidence tells us the strategies are actually working?
- What tradeoffs or failure modes should agents watch for?
- Which of these intents applies to the current product or design work?
- How should Foundry's formation, gates, prompts, and agents be shaped as a
  result?

A useful Alloy record is not a slogan such as "keep code simple." It is closer
to:

```yaml
capability: Test checkout policy without UI or external services
threat: Business rules leak into LiveView event handlers
expectation: Checkout flows and payment rules will change frequently
strategy: Functional core behind a thin LiveView shell
evidence:
  - Domain policy has pure unit tests
  - LiveView handlers delegate rather than decide
  - Tests run without network or browser dependencies
tradeoff: Adds a boundary that may be excessive for trivial CRUD screens
```

That is actionable. It can guide an agent. It can shape a gate. It can inform a
review. It can be validated after a Foundry run.

---

Related: [[vision]] · [[engineering-intent-record]] · [[product-positioning]] · [[problem-statement]]

*Source: Product Brief §3 (Product Thesis).*
