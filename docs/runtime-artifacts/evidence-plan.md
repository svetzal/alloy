---
title: Evidence Plan
summary: A statement of what evidence would prove the relevant capabilities were preserved by a run — broader than gates, mixing machine-checkable and human-reviewed items.
layer: leaf
parent: runtime-artifacts
tags: [evidence, plan, capabilities, runtime]
---

# Evidence Plan

An Evidence Plan states what evidence is required to determine whether the run satisfied intent — what would prove the relevant capabilities were preserved.

Evidence Plans are broader than gates. Some evidence may be machine-checkable; some may require human review. A gate is one way to produce evidence, but an Evidence Plan can also call for observations that no single executable check can confirm.

## Example evidence statements

```text
Domain payment rules are tested without LiveView.
Vendor SDK imports appear only in payment adapters.
Checkout interaction acceptance checks pass.
Foundry trace shows verification gates passed after execution.
No existing tests were weakened or removed.
```

Each statement describes an outcome that, if observed, helps confirm intent was honoured. Some of these map cleanly onto gates (for example, an import-boundary check); others depend on trace inspection or human judgement.

## Related

- [[evidence-and-gates]] — evidence types, status lifecycle, and observations
- [[gate-overlay]] — how some evidence is enforced as executable gates
- [[formation-brief-sections]] — where the Evidence Plan sits within a brief
- [[runtime-artifacts]] — section overview

*Source: Integration Architecture §7.4.*
