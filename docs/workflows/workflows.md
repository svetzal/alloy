---
title: Workflows
summary: The end-to-end journeys Alloy supports, from capturing engineering intent to driving Foundry runs and resolving drift.
layer: section
parent: index
tags: [workflows, overview, journeys]
---

# Workflows

Alloy turns engineering intent into action. This section describes the journeys a developer travels: capturing or extracting intent, implementing work against that intent through Foundry, and keeping the codebase honest as intent and code drift apart.

Two complementary views are documented here. The **five product workflows (A–E)** describe what a user does in Alloy. The **four runtime end-to-end flows** describe how those journeys execute against Foundry through requests and results.

## Product workflows (A–E)

These are the primary product workflows a developer engages with directly in Alloy:

- [[workflow-capture-from-conversation|A — Capture intent from conversation]]: interview a developer to draft and accept intent records, then export a repo-local projection.
- [[workflow-extract-from-codebase|B — Extract intent from codebase]]: inspect an existing codebase, generate hypotheses, and promote accepted ones into intent records.
- [[workflow-implement-epilogue-interaction|C — Implement an Epilogue interaction]]: take an Epilogue interaction, compile a formation brief, and run it through Foundry against engineering intent.
- [[workflow-detect-resolve-drift|D — Detect and resolve intent drift]]: surface code that contradicts active intent and decide how to reconcile it.
- [[workflow-create-foundry-formation|E — Create a new Foundry formation]]: turn a new engineering situation into a formation brief assembled from Foundry blocks.

## Runtime end-to-end flows

The [[end-to-end-flows|four runtime end-to-end flows]] show how these journeys execute against Foundry: validation-only, implement Epilogue interaction, intent drift repair, and strategic improvement.

*Source: Product Brief §22 (Primary Product Workflows); Integration Architecture §21 (End-to-End Flow Examples).*
