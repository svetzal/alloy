---
title: Foundry Execution Request
summary: The narrow, versioned request that triggers a Foundry run by reference — not the whole intent graph.
layer: leaf
parent: runtime-artifacts
tags: [foundry, execution, request, integration]
---

# Foundry Execution Request

A Foundry Execution Request is the narrow request that triggers Foundry. It
references a [[formation-brief|Formation Brief]] by id, version, and digest, and
tells Foundry which entry event, payload, and throttle to use — it should
**not** include the entire Alloy intent graph.

## Fields

- Request ID.
- Project ID.
- Repository/revision context.
- Formation Brief ID.
- Formation Brief digest.
- Entry event.
- Payload.
- Throttle.
- Idempotency key.
- Callback/reporting instructions.

The idempotency key matters because this integration mutates codebases;
duplicate execution is not acceptable. See
[[idempotency-and-correlation|idempotency and correlation]] for how requests are
deduplicated and traced.

## Request shape

```json
{
  "schema_version": "alloy.foundry_execution_request.v1",
  "request_id": "runreq_01HZ...",
  "idempotency_key": "sha256:...",
  "project_id": "checkout-service",
  "repo": {
    "path": "/work/checkout-service",
    "revision": "abc123",
    "branch": "alloy/checkout-payment"
  },
  "brief": {
    "id": "brief_01HZ...",
    "version": 3,
    "digest": "sha256:...",
    "local_path": ".alloy/briefs/brief_01HZ.yaml"
  },
  "foundry": {
    "entry_event": "iteration_requested",
    "throttle": "dry_run",
    "payload": {
      "strategic": true,
      "max_iterations": 3,
      "actions": {
        "iterate": true,
        "maintain": false
      }
    }
  }
}
```

## Worked example

A request as actually issued, including the reporting block that tells Foundry
where to call back and what to return:

```json
{
  "schema_version": "alloy.foundry_execution_request.v1",
  "request_id": "runreq_01HZ_CHECKOUT_PAYMENT",
  "idempotency_key": "sha256:example",
  "project_id": "checkout-service",
  "requested_by": "stacey",
  "requested_at": "2026-06-06T10:05:00-04:00",
  "repo": {
    "path": "/work/checkout-service",
    "revision": "abc123",
    "branch": "alloy/checkout-payment"
  },
  "brief": {
    "id": "brief_01HZ_CHECKOUT_PAYMENT",
    "version": 1,
    "digest": "sha256:example",
    "local_path": ".alloy/briefs/brief_01HZ_CHECKOUT_PAYMENT.yaml"
  },
  "foundry": {
    "entry_event": "iteration_requested",
    "throttle": "dry_run",
    "payload": {
      "strategic": true,
      "max_iterations": 3,
      "actions": {
        "iterate": true,
        "maintain": false
      }
    }
  },
  "reporting": {
    "callback_url": "https://alloy.example.test/api/run-requests/runreq_01HZ_CHECKOUT_PAYMENT/completed",
    "trace_summary_required": true,
    "evidence_observations_required": true
  }
}
```

## Related

- [[formation-brief]] — the artifact this request references.
- [[foundry-run-result]] — what Foundry returns when the run completes.
- [[idempotency-and-correlation]] — deduplication and correlation IDs.
- [[integration-modes]] — how requests are delivered across installations.

*Source: Integration Architecture §7.5, §11.2, §26.*
