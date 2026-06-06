---
title: Extract Intent from Codebase
summary: Workflow B — inspect an existing codebase, generate hypotheses, and promote accepted ones into intent records.
layer: leaf
parent: workflows
tags: [workflow, extract, archaeology, hypothesis]
---

# Workflow B: Extract engineering intent from existing codebase

This workflow recovers latent intent from code that already exists. Alloy's [[codebase-archaeology|codebase archaeology]] inspects the project and emits candidate findings in the [[hypothesis-format|hypothesis format]] for human review.

1. Developer runs `alloy discover`.
2. Alloy inspects structure, tests, gates, docs, and history.
3. Alloy creates hypotheses.
4. Developer reviews hypotheses.
5. Accepted hypotheses become intent records.
6. Alloy identifies missing evidence.
7. Alloy can create a Foundry validation or iteration brief to strengthen the
   evidence.

See also the other [[workflows]] and the conversational counterpart [[workflow-capture-from-conversation]].

*Source: Product Brief §22 (Primary Product Workflows), Workflow B.*
