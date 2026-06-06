---
title: Detect and Resolve Intent Drift
summary: Workflow D — surface code that contradicts active intent and decide how to reconcile it.
layer: leaf
parent: workflows
tags: [workflow, drift, intent, remediation]
---

# Workflow D: Detect and resolve intent drift

This workflow keeps code and intent aligned over time. [[drift-detection|Drift detection]] periodically surfaces contradictions, and a human decides whether each is genuine drift, an allowed exception, or obsolete intent.

1. Alloy periodically inspects codebase and traces.
2. Alloy detects code that contradicts active intent.
3. Alloy asks whether this is drift, exception, or obsolete intent.
4. Human decides.
5. Alloy either updates the intent, creates an exception, or produces a Foundry
   remediation brief.

See also the other [[workflows]] and the runtime repair path in [[end-to-end-flows]].

*Source: Product Brief §22 (Primary Product Workflows), Workflow D.*
