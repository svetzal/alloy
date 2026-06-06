---
title: Runtime Artifact Family
summary: The small family of immutable, versioned artifacts Alloy compiles from intent to form the stable seam to Foundry.
layer: section
parent: index
tags: [runtime, artifacts, integration, overview]
---

# Runtime Artifact Family

Rather than handing Foundry one giant document, Alloy compiles intent into a
family of small, immutable, versioned artifacts. Each artifact has a single job,
a stable schema, and a digest, so a run can always be tied back to the exact
intent snapshot that produced it. Together these artifacts form the stable seam
between Alloy and Foundry: Alloy's job is to compile intent into them, and
Foundry's job is to execute events and task blocks using them, then report
traces and evidence back.

The feedback loop closes the seam. Foundry's results let Alloy update intent
satisfaction, detect drift, expose contradictions, and ask better questions next
time. For who owns which side of this seam, see [[ownership-boundary]].

## The artifacts

- **Formation Brief** — the main runtime artifact: an immutable intent package
  for a specific run or reusable class of runs. See [[formation-brief]], its
  [[formation-brief-sections|required sections]], and its
  [[formation-brief-lifecycle|lifecycle]].
- **Prompt Pack** — phase-specific agent instructions compiled from product,
  design, and engineering intent. See [[prompt-pack]] and
  [[prompt-pack-compilation|how packs are compiled]].
- **Gate Overlay** — proposed or generated gate definitions that express
  required evidence. See [[gate-overlay]].
- **Evidence Plan** — an explicit statement of what would prove the relevant
  capabilities were preserved. See [[evidence-plan]] and
  [[evidence-and-gates|evidence and gates]].
- **Foundry Execution Request** — the narrow, versioned request telling Foundry
  which entry event, payload, throttle, project, and artifact references to use.
  See [[foundry-execution-request]].
- **Foundry Run Result** — the versioned summary, trace references, gate
  outcomes, evidence observations, and feedback returned to Alloy. See
  [[foundry-run-result]].
- **Foundry Capability Manifest** — what a given Foundry installation actually
  supports, so Alloy can compile to a compatible target. See
  [[foundry-capability-manifest]].

*Source: Integration Architecture §7 (intro) and §1 artifact list.*
