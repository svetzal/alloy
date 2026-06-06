---
title: Versioning and Compatibility
summary: Schema versioning of integration artifacts, the compatibility rules between Alloy and Foundry, and the shared contract tests that enforce them.
layer: leaf
parent: integration-architecture
tags: [versioning, compatibility, schemas, contract-tests]
---

# Versioning and Compatibility

## Schema versions

Every integration artifact should carry a schema version.

Examples:

```text
alloy.formation_brief.v1
alloy.prompt_pack.v1
alloy.gate_overlay.v1
alloy.evidence_plan.v1
alloy.foundry_execution_request.v1
alloy.foundry_run_result.v1
foundry.capability_manifest.v1
```

The two cross-system artifacts here are the [[foundry-execution-request]] and the [[foundry-run-result]].

## Compatibility rules

- Foundry-facing schemas should evolve slowly.
- Alloy internal schemas may evolve faster.
- Runners should reject unsupported major versions.
- Minor additions should be ignored by older consumers where safe.
- Deprecated fields should remain readable for audit.
- Compiled briefs should preserve the compiler version.

## Contract tests

Alloy and Foundry should share contract tests for:

- Execution request validation.
- Brief digest verification.
- Capability manifest parsing.
- Run result ingestion.
- Trace summary ingestion.
- Failure classification.

Gaps and proposed additions to these schemas and tests are tracked in the [[specification-backlog]].

*Source: Integration Architecture §20 (Versioning and Compatibility).*
