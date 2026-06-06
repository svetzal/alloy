---
title: Evidence and Gates
summary: The fuller treatment of how evidence relates to gates — evidence types, the evidence status lifecycle, evidence observations from runs, and gate-weakening detection.
layer: leaf
parent: runtime-artifacts
tags: [evidence, gates, status, observations]
---

# Evidence and Gates

Alloy must pressure intent toward evidence. Otherwise it becomes architecture poetry.

## Evidence is broader than gates

A gate is an executable check. **Evidence is any observation that helps determine whether intent was satisfied.** Every gate produces evidence, but not all evidence comes from a gate.

Examples of evidence:

- A test passed.
- An import boundary check passed.
- A trace shows a retry happened.
- A reviewer accepted an architectural explanation.
- A static scan observed a pattern.
- A codebase archaeology hypothesis was confirmed.

## Evidence types

### Automated tests

- Unit tests.
- Contract tests.
- Characterization tests.
- Acceptance tests linked to Epilogue interactions.
- Regression tests for previously observed threats.

### Static checks

- Import-boundary checks.
- Architecture lints.
- Dependency graph checks.
- Framework usage checks.
- Naming or module placement checks.

### Runtime or trace evidence

- Foundry trace confirms expected formation ran.
- Retry only addressed failed evidence.
- No forbidden blocks fired under dry run.
- Agent stopped when intent was ambiguous.

See [[trace-feedback]] for how trace evidence flows back into Alloy.

### Human review evidence

- Developer accepted extracted intent.
- Reviewer confirmed exception is intentional.
- Product owner confirmed ambiguity is resolved.
- Design intent owner confirmed UX constraint was preserved.

## Evidence status lifecycle

Each evidence item should have a status:

- Proposed.
- Required.
- Passing.
- Failing.
- Waived.
- Obsolete.
- Unknown.

A waived evidence item must capture who waived it, why, and when it should be reviewed again. (Waiver authority is governed by [[security-and-authority]].)

## Evidence observations

A [[foundry-run-result]] should produce Evidence Observations: records of what a run actually observed against a defined evidence item.

```json
{
  "schema_version": "alloy.evidence_observation.v1",
  "evidence_definition_id": "evidence_01HZ...",
  "run_request_id": "runreq_01HZ...",
  "brief_id": "brief_01HZ...",
  "status": "partially_satisfied",
  "observed_by": "foundry",
  "supporting_artifacts": [
    "trace://foundry_run_01HZ/gates/tests",
    "repo://checkout-service/def456/test/payment_rules_test.exs"
  ],
  "notes": "Domain tests passed, but one LiveView handler still contains policy branching."
}
```

## Gate overlays

Alloy generates or selects [[gate-overlay]]s that Foundry can resolve, rather than running a parallel validation runtime. An overlay turns required evidence into executable gates with enforcement modes; see [[gate-overlay]] for the modes and an example. The broader picture of what should be proved lives in the [[evidence-plan]].

## Gate weakening detection

Alloy should treat removal or weakening of gates and tests as a suspicious move unless explicitly authorized.

Foundry may detect the file changes. Alloy should interpret those changes against the brief — a dropped or loosened test is evidence that a protected capability may have been silently abandoned.

## Related

- [[gate-overlay]] — gates as executable, enforced evidence
- [[evidence-plan]] — the plan that states what to prove
- [[trace-feedback]] — runtime/trace evidence feeding back to Alloy
- [[foundry-run-result]] — where evidence observations are recorded
- [[security-and-authority]] — authority over waivers and gate weakening
- [[runtime-artifacts]] — section overview

*Source: Product Brief §18; Integration Architecture §15.*
