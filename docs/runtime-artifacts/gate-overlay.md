---
title: Gate Overlay
summary: An artifact that proposes or defines additional gates for a run, in one of three enforcement modes, feeding Foundry better gate definitions rather than a parallel validation runtime.
layer: leaf
parent: runtime-artifacts
tags: [gates, evidence, overlay, runtime]
---

# Gate Overlay

A Gate Overlay proposes or defines additional gates for a run. Each gate expresses required evidence as an executable check. Gate overlays should be reviewable: some may be advisory at first, and others may become required gates.

Alloy should not replace Foundry's gate orchestration. Foundry already has a gate lifecycle. **Alloy should feed it better gate definitions, not create a parallel validation runtime.** Alloy generates or selects gate overlays that Foundry can resolve.

## Example gates

An overlay may name checks such as:

```text
architecture_import_boundary
liveview_domain_logic_check
vendor_sdk_isolation_check
domain_test_without_ui_check
contract_test_check
```

## Enforcement modes

Gate Overlays support three modes, ordered by strictness:

- **Advisory** — The gate is suggested but not enforced.
- **Required for dry-run satisfaction** — The gate must pass for Alloy to consider the dry-run sufficient, but Foundry may not block execution.
- **Required for mutating completion** — The gate must pass before a mutating run is considered complete.

This lets a gate begin as advisory and harden over time, without Alloy duplicating the runtime that actually enforces it.

## Example overlay

```yaml
gate_overlay:
  id: alloy.gate.payment-boundary
  applies_to:
    - alloy.intent.gateway.payment-provider
  gates:
    - name: payment_vendor_import_boundary
      command: ./scripts/check-payment-import-boundary.sh
      required: true
      timeout_secs: 30
```

## Related

- [[evidence-and-gates]] — the fuller treatment of how gates relate to evidence
- [[evidence-plan]] — the broader evidence statements gates partially satisfy
- [[runtime-artifacts]] — section overview

*Source: Integration Architecture §7.3, §15.2; Product Brief §18.*
