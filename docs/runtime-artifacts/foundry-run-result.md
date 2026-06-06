---
title: Foundry Run Result
summary: The versioned record Foundry returns — status, gate outcomes, trace references, evidence observations, and feedback.
layer: leaf
parent: runtime-artifacts
tags: [foundry, run-result, trace, feedback, integration]
---

# Foundry Run Result

A Foundry Run Result records what happened during a run. It is what Foundry
reports back to Alloy in response to a
[[foundry-execution-request|Foundry Execution Request]], closing the feedback
loop so Alloy can update intent satisfaction and surface findings.

## Fields

- Foundry run ID.
- Alloy run request ID.
- Formation Brief ID and digest.
- Project and repository revision before/after.
- Status.
- Gate results.
- Retry count.
- Commit/push results where applicable.
- Trace references.
- Summary.
- Evidence observations.
- Follow-up questions.
- Errors and failure classification.

The summary and evidence observations feed [[evidence-and-gates|evidence and
gates]] interpretation; the follow-up questions and threats feed
[[trace-feedback|trace feedback]] back into intent.

## Run result shape

```json
{
  "schema_version": "alloy.foundry_run_result.v1",
  "run_request_id": "runreq_01HZ...",
  "foundry_run_id": "foundry_run_01HZ...",
  "brief_id": "brief_01HZ...",
  "brief_digest": "sha256:...",
  "project_id": "checkout-service",
  "status": "completed",
  "repo_revision_before": "abc123",
  "repo_revision_after": "def456",
  "throttle": "dry_run",
  "entry_event": "iteration_requested",
  "gates": [
    {
      "name": "tests",
      "phase": "verify",
      "status": "passed"
    }
  ],
  "summary": {
    "capabilities_preserved": [
      "Business rules remain testable without LiveView"
    ],
    "threats_observed": [
      "One LiveView handler still contains policy branching"
    ],
    "follow_up_questions": [
      "Should this branching be accepted as UI state, or moved into the functional core?"
    ]
  }
}
```

## Trace summary shape

Foundry traces may be richer than Alloy needs for first-pass interpretation.
Alloy should accept both a full trace export and a condensed trace summary. A
summary should include:

- Root event.
- Entry event.
- Blocks executed.
- Blocks skipped by throttle.
- Mutators simulated or executed.
- Gate phases.
- Gate outcomes.
- Retry requests.
- Terminal event.
- Commit/push outcomes.
- Errors.
- Correlation IDs.

See [[observability-and-audit]] for how traces are retained and audited.

## Worked example

A result reporting findings — a passing test gate alongside a failed import
boundary gate, with capabilities at risk and a follow-up question:

```json
{
  "schema_version": "alloy.foundry_run_result.v1",
  "run_request_id": "runreq_01HZ_CHECKOUT_PAYMENT",
  "foundry_run_id": "foundry_run_01HZ_CHECKOUT_PAYMENT",
  "brief_id": "brief_01HZ_CHECKOUT_PAYMENT",
  "brief_digest": "sha256:example",
  "project_id": "checkout-service",
  "status": "completed_with_findings",
  "repo_revision_before": "abc123",
  "repo_revision_after": "def456",
  "throttle": "dry_run",
  "entry_event": "iteration_requested",
  "retry_count": 1,
  "gates": [
    {
      "name": "mix test",
      "phase": "verify",
      "status": "passed"
    },
    {
      "name": "vendor_sdk_import_boundary",
      "phase": "verify",
      "status": "failed",
      "details": "Stripe SDK imported in CheckoutLive."
    }
  ],
  "summary": {
    "capabilities_preserved": [
      "Checkout payment rules can be tested without external services."
    ],
    "capabilities_at_risk": [
      "Payment providers can be replaced without changing LiveView modules."
    ],
    "threats_observed": [
      "Vendor SDK leakage into UI shell."
    ],
    "follow_up_questions": [
      "Should the CheckoutLive import be moved behind the payment gateway before full mutation is approved?"
    ]
  }
}
```

## Related

- [[foundry-execution-request]] — the request this result answers.
- [[trace-feedback]] — how results update intent records.
- [[evidence-and-gates]] — interpreting gate outcomes and evidence observations.
- [[observability-and-audit]] — trace retention and audit.

*Source: Integration Architecture §7.6, §11.3, §11.4, §27.*
