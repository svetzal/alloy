---
title: Integration Modes
summary: The phased evolution from manual file projection through CLI adapter, runner pull, and native Foundry integration to configurable composition.
layer: leaf
parent: integration-architecture
tags: [modes, phases, integration]
---

# Integration Modes

The integration should evolve in phases. These modes map onto the [[phased-integration-plan]].

## Mode 0: Manual projection

Alloy generates files for the developer to use manually.

Example output:

```text
.alloy/
  briefs/
    checkout-payment.yaml
  prompts/
    assessment.md
    planning.md
    execution.md
    retry.md
    summary.md
  gates/
    overlay.hone-gates.json
  projections/
    CHARTER.generated.md
```

The developer then invokes Foundry using an existing prompt or strategic prompt mechanism.

This proves value before Foundry changes.

## Mode 1: CLI adapter

Alloy or a bridge invokes the Foundry CLI.

Example:

```bash
foundry emit iteration_requested checkout-service \
  --throttle dry_run \
  --payload '{"strategic": true, "max_iterations": 3, "alloy_brief_path": ".alloy/briefs/checkout-payment.yaml"}'
```

This still avoids native Foundry changes if the relevant blocks can read local prompt/context files. See [[cli]] for the command surface.

## Mode 2: Runner pull model

A runner polls Alloy for run requests.

Flow:

```text
Alloy creates Run Request.
Runner polls Alloy.
Runner downloads compiled artifacts.
Runner materializes artifacts locally.
Runner invokes Foundry.
Runner posts result and trace summary back.
```

This supports hosted Alloy without direct inbound access to developer machines.

## Mode 3: Native Foundry integration

Foundry accepts an `alloy_brief_id` or `alloy_brief_uri` in event payloads and resolves the compiled brief through a configured provider.

Possible event payload:

```json
{
  "strategic": true,
  "max_iterations": 3,
  "alloy": {
    "brief_id": "brief_01HZ...",
    "brief_digest": "sha256:...",
    "prompt_pack_id": "prompt_pack_01HZ...",
    "evidence_plan_id": "evidence_plan_01HZ..."
  }
}
```

This depends on the [[foundry-execution-request]] shape and the provider advertised in the [[foundry-capability-manifest]].

## Mode 4: Configurable Foundry composition

When Foundry's composition layer has been extracted, Alloy can compile not only runtime context but also formation composition configuration.

This should remain a later phase. The early product should not depend on this extraction.

## Related

- [[integration-architecture]] — section overview.
- [[phased-integration-plan]] — the rollout these modes support.
- [[foundry-execution-request]] — the request shape used from Mode 3 on.
- [[foundry-capability-manifest]] — what Foundry advertises it can resolve.
- [[cli]] — the Foundry command surface used in Mode 1.

*Source: Integration Architecture §10 (Integration Modes).*
