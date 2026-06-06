---
title: Runtime Entities
summary: The integration and execution entities added by the Foundry runtime architecture, from installations and runners through run results and trace imports.
layer: leaf
parent: data-model
tags: [data-model, runtime, foundry, integration]
---

# Runtime Entities

The product brief defines the broad [[data-model]] seed. The Foundry runtime
integration architecture adds these runtime-specific entities — the
installations, runners, compiled artifacts, requests, results, and traces that
drive and record execution. Related concepts include the
[[foundry-execution-request]], the [[foundry-run-result]], the
[[foundry-capability-manifest]], and the [[runtime-topology]].

## foundry_installations

Represents a Foundry runtime Alloy can target.

- id
- project_id or organization_id
- name
- foundry_version
- connection_type
- last_seen_at
- capability_manifest
- status

The `capability_manifest` field carries the [[foundry-capability-manifest]].

## alloy_runners

Represents a runner or bridge process. See [[runtime-topology]] for how
runners fit into the deployment.

- id
- organization_id
- name
- runner_key_hash
- allowed_projects
- status
- last_poll_at
- last_heartbeat_at
- registered_by
- registered_at

## formation_brief_compilations

Represents a compiled brief instance.

- id
- brief_template_id nullable
- project_id
- source_intent_snapshot
- compiled_payload
- compiler_version
- schema_version
- digest
- status
- created_by
- created_at
- approved_by nullable
- approved_at nullable

## prompt_pack_compilations

Represents compiled prompts.

- id
- formation_brief_id
- template_version
- compiler_version
- prompts
- human_edits
- schema_version
- digest
- created_at

## gate_overlays

Represents generated or accepted gate overlays.

- id
- formation_brief_id
- project_id
- mode
- content
- digest
- status
- created_at
- approved_by nullable

## foundry_run_requests

Represents a request for Foundry execution. See
[[foundry-execution-request]].

- id
- project_id
- runner_id nullable
- formation_brief_id
- brief_digest
- entry_event
- payload
- throttle
- repo_revision
- branch
- idempotency_key
- status
- requested_by
- requested_at
- accepted_at nullable
- started_at nullable
- completed_at nullable

## foundry_run_results

Represents Foundry's terminal result. See [[foundry-run-result]].

- id
- run_request_id
- foundry_run_id
- status
- repo_revision_before
- repo_revision_after
- gate_results
- retry_count
- trace_uri
- summary
- raw_result
- completed_at

## trace_imports

Represents raw or summarized trace data imported from Foundry.

- id
- foundry_run_result_id
- trace_id
- trace_format
- raw_trace
- summary
- imported_at

## evidence_observations

Represents evidence found during or after execution.

- id
- evidence_definition_id
- run_request_id
- formation_brief_id
- status
- observed_by
- supporting_artifacts
- notes
- observed_at

*Source: Integration Architecture §17 (Data Model Additions).*
