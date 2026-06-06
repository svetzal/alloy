---
title: Capture Intent from Conversation
summary: Workflow A — interview a developer to draft, accept, and export engineering intent records.
layer: leaf
parent: workflows
tags: [workflow, capture, intent, interview]
---

# Workflow A: Capture engineering intent from conversation

This workflow captures engineering intent through a guided interview. Alloy's [[elicitation-assistants|elicitation assistants]] drive the conversation, and the resulting [[evidence-plan|evidence plan]] determines how that intent will be checked.

1. Developer starts an Alloy interview.
2. Alloy asks about technology choices, boundaries, scars, angry PRs, and
   local definitions of principles.
3. Alloy drafts intent records.
4. Developer edits and accepts records.
5. Alloy proposes evidence and gates.
6. Developer accepts, edits, or defers evidence.
7. Alloy exports a repo-local projection for agents and Foundry.

See also the other [[workflows]] and the related extraction journey [[workflow-extract-from-codebase]].

*Source: Product Brief §22 (Primary Product Workflows), Workflow A.*
