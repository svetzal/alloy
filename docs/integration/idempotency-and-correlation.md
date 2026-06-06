---
title: Idempotency and Correlation
summary: How Alloy guarantees a single mutation per intent and reconstructs exactly what ran against what.
layer: leaf
parent: integration-architecture
tags: [idempotency, correlation, retry, audit]
---

# Idempotency and Correlation

This integration will mutate codebases. Duplicate execution is not acceptable. Because a [[foundry-execution-request]] can change source code, every execution path must be traceable and safe to retry.

## Required identifiers

Every execution path should carry:

```text
formation_brief_id
formation_brief_digest
run_request_id
foundry_run_id
idempotency_key
project_id
repo_revision_before
repo_revision_after
trace_id
span_id
correlation_id
runner_id
```

## Idempotency key

The idempotency key should be derived from:

```text
project_id
repo_revision
brief_digest
entry_event
payload
throttle
requested_by
```

A second request with the same idempotency key should not trigger a second mutation without explicit human override. This is the mechanical guard that keeps a re-sent request from producing a second change to the repository — see [[security-and-authority]] for the human override path.

## Retry semantics

There are at least three kinds of retry:

1. **Transport retry**: a network call is retried because the client did not receive a response.
2. **Runner retry**: a runner crashed or restarted after accepting work.
3. **Foundry execution retry**: Foundry's own bounded retry after gate failure.

These must not be conflated.

Alloy should model them separately so users can distinguish infrastructure failures from engineering failures. The distinction maps directly onto the failure categories in [[failure-handling]].

## Exact snapshot rule

A Foundry run should answer:

> Did this exact Foundry run execute this exact Alloy brief against this exact repository revision?

If the answer cannot be reconstructed, the integration is not sufficiently auditable. The identifiers above, recorded on the [[foundry-run-result]] and surfaced through [[observability-and-audit]], are what make that reconstruction possible.

*Source: Integration Architecture §12 (Idempotency and Correlation).*
