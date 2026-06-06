---
title: Runtime Topology
summary: The recommended runner-initiated topology and its local-only, hosted, and enterprise self-hosted variants.
layer: leaf
parent: integration-architecture
tags: [topology, runner, deployment]
---

# Runtime Topology

## Recommended topology

The preferred topology is:

```text
Alloy Web App
  Phoenix / LiveView / PostgreSQL
  Owns users, projects, intent graph, briefs, prompt packs, run requests

        outbound/pull or secure API boundary

Alloy Runner / Foundry Bridge
  Runs near codebase and foundryd
  Owns local repo access, local secrets, local tools

        gRPC or CLI boundary

Foundry Daemon
  Rust engine
  Owns events, task blocks, throttle, gates, traces, side effects

        filesystem/process/git boundary

Repository and Toolchain
  Source code, tests, package managers, linters, CI hooks
```

The runner should usually initiate outbound communication to Alloy. That is safer than requiring a hosted Alloy server to reach directly into developer machines or internal networks.

## Why not direct hosted control

A hosted Alloy server should not directly SSH into workstations or mutate repositories by itself. That creates too much authority in the user-facing application layer.

A runner model localizes authority:

- Repository credentials stay near the repository.
- Package managers and local toolchains stay local.
- Network firewalls are easier to handle.
- Foundry can continue operating as a local/system-level tool.
- Alloy remains the administration and control-plane product.

See [[security-and-authority]] for how authority and credentials are scoped across the seam.

## Local-only topology

For early development, Alloy may run locally beside Foundry:

```text
localhost: Alloy Phoenix app
localhost: PostgreSQL
localhost: foundryd
localhost: repositories
```

This is likely the lowest-friction development topology. It avoids runner complexity while still preserving the logical boundary between Alloy and Foundry.

## Hosted topology

A later hosted topology would likely include:

```text
Alloy Cloud
  Multi-tenant Phoenix app
  Tenant/project authorization
  Intent graph storage
  Brief compilation
  Run request queue

Customer Runner
  Registered with Alloy
  Polls for run requests
  Executes through Foundry
  Posts trace/evidence back
```

This resembles GitHub Actions runners more than a centralized remote-control system.

## Enterprise self-hosted topology

An enterprise version may keep everything inside the customer's environment:

```text
Alloy Enterprise
  Phoenix app in private infrastructure
  PostgreSQL in private infrastructure

Foundry Runners
  Per team, repo group, or platform domain

Foundry Daemons
  Local or controlled automation hosts
```

This may be necessary where code, prompts, traces, and intent records are sensitive.

## Related

- [[integration-architecture]] — section overview.
- [[system-roles]] — what runs at each node, including the runner/bridge.
- [[security-and-authority]] — authority localization.
- [[integration-modes]] — how the topology is reached in phases.

*Source: Integration Architecture §6 (Runtime Topology).*
