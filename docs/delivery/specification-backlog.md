---
title: Specification Backlog
summary: The likely next specification documents, grouped into a product-spec backlog and an integration-spec backlog.
layer: leaf
parent: delivery
tags: [backlog, specifications, schemas, planning]
---

# Specification Backlog

This page identifies the specification documents that are likely to be written
next. It merges two backlogs: the product-spec backlog from the Product Brief and
the integration-spec backlog from the Integration Architecture.

## Product-spec backlog

### Engineering Intent Record specification

Define:

- Full schema.
- Validation rules.
- Lifecycle states.
- Relationship types.
- Versioning rules.
- Source attribution.
- Confidence model.

### Formation Brief specification

See [[formation-brief]]. Define:

- YAML/JSON schema.
- Required and optional fields.
- Foundry payload mapping.
- Prompt pack references.
- Gate overlay references.
- Compatibility rules.

### Prompt Pack compiler specification

See [[prompt-pack]]. Define:

- Input context.
- Phase-specific prompt templates.
- Token budgeting.
- Context prioritization.
- Source inclusion rules.
- Output formats.

### Codebase Archaeologist specification

See [[codebase-archaeology]]. Define:

- Repository scanning strategy.
- Supported languages.
- Signal extraction.
- Confidence scoring.
- Hypothesis format.
- Human review flow.

### Foundry integration specification

See [[integration-modes]]. Define:

- Integration mode 1: projection through existing prompts.
- Integration mode 2: local brief resolver.
- Integration mode 3: native Foundry task blocks/events.
- Trace ingestion protocol.
- Gate overlay protocol.

### Epilogue Tracker integration specification

Define:

- Entity references.
- Product intent query shape.
- Interaction selection.
- Traceability from product work to engineering intent.
- Avoiding duplication of product intent records.

### Drift detection specification

See [[drift-detection]]. Define:

- Drift signal types.
- Severity model.
- Human decision flow.
- Foundry remediation brief generation.

## Integration-spec backlog

### Formation Brief schema

See [[formation-brief]]. Define:

- Required fields.
- Optional fields.
- Source intent references.
- Snapshot semantics.
- Digest calculation.
- Human approval metadata.
- Compatibility rules.

### Prompt Pack schema

See [[prompt-pack]]. Define:

- Phase names.
- Prompt inputs.
- Prompt outputs.
- Template versioning.
- Human edit tracking.
- Prompt digest calculation.

### Gate Overlay schema

See [[gate-overlay]]. Define:

- Gate names.
- Gate modes.
- Commands or adapters.
- Required evidence mapping.
- Compatibility with Foundry gate resolution.

### Evidence Plan schema

See [[evidence-plan]]. Define:

- Evidence definition types.
- Machine-checkable evidence.
- Human-review evidence.
- Trace evidence.
- Evidence status lifecycle.

### Foundry Execution Request schema

See [[foundry-execution-request]]. Define:

- Required identifiers.
- Repository context.
- Throttle.
- Entry event.
- Payload constraints.
- Idempotency.
- Authorization metadata.

### Foundry Run Result schema

See [[foundry-run-result]]. Define:

- Status values.
- Gate result structure.
- Trace references.
- Retry reporting.
- Commit/push reporting.
- Evidence observation embedding.
- Failure classification.

### Runner protocol

Define:

- Registration.
- Authentication.
- Polling.
- Heartbeat.
- Artifact download.
- Result upload.
- Cancellation.
- Lease expiry.

### Security model

Define:

- User roles.
- Project permissions.
- Runner permissions.
- Approval gates.
- Branch policies.
- Secret boundaries.
- Audit events.

Up: [[delivery]]

*Source: Product Brief §29 (Specification Work Backlog); Integration Architecture §23 (Specification Backlog).*
