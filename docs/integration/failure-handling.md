---
title: Failure Handling
summary: Classifying failures, defining when to stop, and the recovery actions available when a run cannot proceed.
layer: leaf
parent: integration-architecture
tags: [failure, recovery, stop-conditions, safety]
---

# Failure Handling

## Failure categories

Alloy should classify failures so users know what kind of intervention is needed.

### Validation failure

The brief cannot be compiled or approved.

Examples:

- Missing source intent.
- No protected capability selected.
- No evidence plan.
- Incompatible Foundry target.

### Dispatch failure

The request could not reach a runner or Foundry.

Examples:

- Runner offline.
- Foundry daemon unavailable.
- Capability manifest mismatch.

### Execution failure

Foundry ran but could not complete the work.

Examples:

- Agent failed.
- Tool command failed.
- Test failure.
- Gate failure after retry.

### Safety failure

The run attempted or proposed something forbidden.

Examples:

- Test weakening.
- Gate removal.
- Unauthorized mutation.
- Repository revision mismatch.

Safety failures are the enforcement edge of [[security-and-authority]] — they mark an attempt to cross a boundary that the authority model forbids.

### Semantic failure

The work revealed a problem with the intent itself.

Examples:

- Two accepted intent records conflict.
- Evidence cannot be collected because the strategy is vague.
- The expected future change no longer appears plausible.

## Stop conditions

Alloy and Foundry should stop, rather than continue, when:

- The brief digest does not match.
- The repository revision does not match the approved revision and no drift policy allows it.
- A required human approval is missing.
- The runner is not authorized for the project.
- A mutating request is submitted to an untrusted runner.
- The prompt pack has been edited after approval.
- A required gate is missing.
- The agent proposes weakening evidence to pass.

Several of these conditions depend on the identifiers and digest checks described in [[idempotency-and-correlation]]; a revision mismatch is what [[drift-detection]] is designed to surface before a run begins.

## Recovery patterns

Possible recovery actions:

- Recompile brief against current intent.
- Re-approve against current repository revision.
- Switch from full to dry-run.
- Narrow the formation scope.
- Ask a human clarification question.
- Mark an intent record as contradicted.
- Create a smaller repair brief.
- Re-run validation only.

*Source: Integration Architecture §18 (Failure Handling).*
