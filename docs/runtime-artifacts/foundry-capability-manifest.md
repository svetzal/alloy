---
title: Foundry Capability Manifest
summary: How Foundry advertises what it supports so Alloy can compile to the lowest compatible target.
layer: leaf
parent: runtime-artifacts
tags: [foundry, capabilities, compatibility, integration]
---

# Foundry Capability Manifest

Alloy should not assume that every Foundry installation supports every desired
integration feature. Versions differ, blocks differ, and some installations will
lack native support for [[formation-brief|Formation Briefs]],
[[prompt-pack|Prompt Packs]], [[gate-overlay|Gate Overlays]], or trace export.
To handle this, Foundry exposes a capability manifest, and Alloy reads it before
compiling.

## Manifest goals

The manifest lets Alloy know:

- Which Foundry version is present.
- Which event types are supported.
- Which formations are available by entry event/payload convention.
- Which task blocks are registered.
- Which throttle modes are supported.
- Whether Formation Brief references are supported natively.
- Whether Prompt Packs can be resolved natively.
- Whether Gate Overlays are supported.
- Whether trace export is available.
- Whether streaming run updates are available.

## Example capability manifest

```json
{
  "schema_version": "foundry.capability_manifest.v1",
  "foundry_version": "0.12.0",
  "supports_alloy_brief": true,
  "supports_prompt_pack": true,
  "supports_gate_overlay": false,
  "supports_trace_export": true,
  "supported_entry_events": [
    "iteration_requested",
    "execution_requested",
    "maintenance_requested",
    "validation_requested",
    "scan_requested"
  ],
  "supported_throttle_modes": ["dry_run", "full"],
  "registered_blocks": [
    "Check Charter",
    "Resolve Gates",
    "Run Preflight Gates",
    "Assess Project",
    "Triage Assessment",
    "Create Plan",
    "Execute Plan",
    "Run Verify Gates",
    "Route Gate Result",
    "Retry Execution",
    "Summarize Result",
    "Commit and Push"
  ]
}
```

## Compile to the lowest compatible target

Given the manifest, Alloy compiles to the lowest compatible target so a run
still works on a less capable installation. For example:

- If native Formation Brief resolution is unavailable, Alloy materializes brief
  and prompt files into the repository.
- If Gate Overlays are unavailable, Alloy generates advisory checklists or
  repo-local gate files.
- If trace export is unavailable, Alloy accepts manual trace ingestion or
  summarized CLI output.

This is what lets Alloy meet a given Foundry where it is — see
[[integration-modes]] for the modes that result, and
[[versioning-and-compatibility]] for how schema versions are negotiated over
time.

*Source: Integration Architecture §9.*
