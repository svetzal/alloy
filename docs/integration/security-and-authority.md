---
title: Security and Authority
summary: The high-authority boundary controlling who may mutate code, how briefs are verified, and how untrusted repository content is contained.
layer: leaf
parent: integration-architecture
tags: [security, authority, approvals, secrets]
---

# Security and Authority

Alloy is user-facing. Foundry can mutate code. The boundary must be designed as a high-authority boundary.

## Authority model

Alloy should represent at least these authorities:

- Can view engineering intent.
- Can create or edit intent hypotheses.
- Can accept active intent records.
- Can compile Formation Briefs.
- Can approve dry-run execution.
- Can approve mutating execution.
- Can approve commit/push.
- Can approve release-related actions.
- Can register or rotate runners.
- Can manage project secrets and runner permissions.

## Dry-run default

New briefs, new projects, new runners, and new integration modes should default to dry-run.

Foundry's throttle model is a good safety seam. Alloy should use it deliberately.

## Brief signing and digest verification

A runner should verify that the Formation Brief it executes matches the digest in the Foundry Execution Request.

A later version should support signing:

```text
brief digest
approved by
approval timestamp
approval scope
signature
```

This verification step closes the loop with the [[formation-brief-lifecycle]]: a brief whose digest no longer matches its approved form must not run.

## Secrets boundary

Alloy should avoid storing credentials needed to mutate repositories wherever possible.

Prefer:

```text
Alloy stores intent and approvals.
Runner stores or accesses local credentials.
Foundry performs local execution.
```

This split maps onto the [[runtime-topology]]: credentials live with the runner, not in the user-facing plane.

## Branch isolation

Mutating execution should default to an isolated branch.

Example branch naming:

```text
alloy/<project>/<brief-slug>/<short-id>
```

## Human approval gates

Some transitions should require explicit human approval:

- Dry-run to full mutation.
- Commit/push after automated changes.
- Gate weakening.
- Deleting tests.
- Rewriting accepted intent records.
- Running a brief whose source intent has changed since compilation.
- Running a brief whose target repository revision differs from the approved revision.

These gates are reinforced by the evidence checks in [[evidence-and-gates]]; an attempt to bypass one is a safety failure under [[failure-handling]].

## Prompt injection and repository content

Codebase archaeology and prompt compilation will consume repository content. Alloy should treat repository text as untrusted input.

At minimum:

- Separate instructions from observed content.
- Clearly label codebase observations.
- Avoid letting repository text override system or developer instructions.
- Record which files informed a hypothesis.
- Require human validation before accepting extracted intent.

*Source: Integration Architecture §13 (Security and Authority).*
