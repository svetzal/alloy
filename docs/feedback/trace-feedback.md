---
title: Trace Feedback
summary: How Foundry execution traces become learning input for Alloy through an intent-interpretation layer.
layer: section
parent: index
tags: [feedback, traces, learning]
---

# Trace Feedback

Foundry traces become learning input for Alloy. Foundry answers *what happened* — which blocks ran, which events were emitted, which gates passed, which retries occurred, and what payloads moved through the event chain. Alloy adds an **intent-interpretation layer** on top of that raw record, asking what the run meant for the accepted intent graph.

This section sits under [[index]] and feeds the [[learning-loop]] that closes the gap between intent and running code.

## Trace-interpretation questions

After a Foundry run, Alloy asks:

- Which intent records were in scope?
- Which capabilities were preserved?
- Which capabilities were harmed?
- Which threats were observed or appeared?
- Which strategies were applied, and which worked?
- Which strategies proved too expensive?
- Which tradeoffs became visible?
- Which expected evidence was collected, and which remained unknown?
- Which evidence passed or failed?
- Did retry behaviour stay within the intended scope?
- Did the run reveal missing intent?
- Did the run contradict accepted intent?
- Did the agent need guidance that Alloy did not provide?
- Which intent records need refinement?
- Which human questions should be asked next?

These questions read against the [[foundry-run-result]] and the [[evidence-and-gates]] that the run emitted.

## Feedback outputs

From those questions, Alloy can produce feedback records such as:

- Capability satisfaction status
- Threat observation
- Evidence observation
- Intent drift event
- Contradicted expectation
- Strategy effectiveness note
- Tradeoff observation
- Human clarification question
- Proposed new intent record
- Proposed deprecation of an old intent record

## Where this goes next

- [[learning-loop]] — the full closed loop from intent records back to an updated intent graph, with the `run_feedback` output.
- [[drift-detection]] — when the codebase no longer reflects accepted intent.
- [[contradiction-detection]] — when the code is fine but the intent itself is stale.

*Source: Product Brief §19; Integration Architecture §16.1–16.2.*
