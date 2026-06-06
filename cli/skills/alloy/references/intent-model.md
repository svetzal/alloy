# The Engineering Intent Model

The conceptual model behind Alloy's records. For the commands that read and
write them, see [cli-reference.md](cli-reference.md).

## The judgement

An Engineering Intent Record expresses one future-facing engineering judgement:

> We need to preserve this **capability** because this **threat** matters under
> this **expectation**, so we prefer this **strategy**, require this
> **evidence**, and accept this **tradeoff**.

Decomposing the sentence into six fields keeps the decision specific and
checkable. A good record reads back as that single sentence with each blank
filled by one of its fields.

## The six fields

### Capability — the ability to retain

What the system or team must keep being able to do.

- Business rules can be tested without UI, network, or database dependencies.
- External service providers can be replaced without rewriting domain logic.
- Failure semantics remain stable for consumers.
- The system can be deployed safely after small changes.

### Threat — the force that erodes it

The specific way the capability degrades if no one guards it.

- Business logic leaking into UI event handlers.
- Vendor SDK types spreading into domain modules.
- Ad hoc string errors escaping into API responses.
- Tests coupled to implementation details.
- Agent-generated code bypassing existing boundaries.

### Expectation — why the threat matters

The future change, uncertainty, or pressure that makes the threat worth
defending against *now*. Without an expectation, a threat is hypothetical.

- Payment providers are likely to change.
- UI flows will evolve faster than domain policy.
- More consumers will integrate with this API.
- The team expects autonomous agents to make frequent changes.

### Strategy — the approach that protects it

The technical or social means of preserving the capability against the threat.

- Functional core / imperative shell.
- Gateway abstractions behind behaviours.
- Typed domain errors.
- Contract tests; architecture import-boundary checks.
- Thin LiveView handlers delegating to domain services.

### Evidence — observable proof it is working

What you can actually look at to confirm the strategy is holding. Evidence is
checkable, not aspirational.

- Domain tests run without a database.
- Vendor SDK imports appear only in adapter modules.
- Error responses are generated from typed domain errors.
- A CI gate enforces import boundaries.
- PR review confirms intent records were preserved.

### Tradeoff — the cost it introduces

The downside, ceremony, or failure mode the strategy brings. **This field is
what keeps a record honest.** A strategy presented with no cost is dogma; naming
the tradeoff makes the judgement falsifiable and lets future readers re-weigh it.

- Gateway abstractions can become ceremony when volatility is low.
- Functional-core boundaries can be over-applied to simple CRUD.
- Strongly typed errors require additional mapping layers.
- Import-boundary gates annoy developers when the boundaries are unclear.

## Confidence

Each record carries a `confidence` in `[0.0, 1.0]`. Records extracted by tooling
or inferred from code start low; records a human has confirmed approach `1.0`.
Confidence is orthogonal to lifecycle status — a `proposed` record can be
high-confidence, and an `active` one can carry residual uncertainty.

## Keys and slugs

- Each record has a **slug** unique within its project, matching
  `^[a-z0-9_-]+$` (lowercase letters, digits, underscores, hyphens).
- The slug is derived from the title when not given explicitly, and is
  **immutable after creation** — it is the stable handle other things reference.
- The fully-qualified, cross-project key is `<project_key>.intent.<slug>`, e.g.
  `alloy.intent.preserve-testability`. The CLI uses the bare slug because the
  configured token already scopes to one project; use the full key in prose,
  AGENTS.md, or anywhere a project is not implied.

## Lifecycle

Records move through states because extracted intent is often a hypothesis, not
a fact:

| Status | Meaning | Set by |
|--------|---------|--------|
| `hypothesized` | Tooling believes this intent may exist; unconfirmed | codebase archaeology, trace analysis |
| `proposed` | Drafted and ready for review (**default on create**) | a human or assistant |
| `accepted` | A qualified human confirmed it should guide work | `accept` |
| `active` | Accepted and currently guiding work | `activate` |
| `deprecated` | No longer generally applicable; history retained | `deprecate` |
| `contradicted` | Shown untrue or conflicting — **terminal** | `contradict` |
| `superseded` | Replaced by a newer record — **terminal** | `supersede` |

### Legal transitions

```
accept:     hypothesized | proposed                          → accepted
activate:   accepted                                         → active
deprecate:  accepted | active                                → deprecated
contradict: hypothesized | proposed | accepted | active | deprecated → contradicted
supersede:  hypothesized | proposed | accepted | active | deprecated → superseded
```

`contradicted` and `superseded` are terminal: no transition lists them as a
source, so a record in either state can no longer move. An attempt at an illegal
transition is rejected and the record is unchanged.

### Lifecycle principles

- Codebase extraction defaults to **hypothesized**, not **accepted** — the
  system may be wrong about inferred intent.
- Human-entered records may start as **proposed**.
- Only **accepted** or **active** records should guide downstream execution
  (e.g. Foundry) by default.
- **Hypothesized** records are prompts for human clarification, not hard
  constraints.
- `supersede --by <slug>` records lineage: prefer it over `contradict` +
  recreate when a record is being *refined* rather than *refuted*.

## Validation rules

`alloy validate` checks referential integrity and reports `errors` (must fix)
and `warnings` (should review):

- **Error** — a record's slug is malformed (does not match `^[a-z0-9_-]+$`).
- **Error** — duplicate slugs within the project.
- **Error** — a record carries an unknown lifecycle status.
- **Error** — a record's supersede link (its `supersedes_slug` predecessor) does
  not resolve to an existing record in the project.
- **Warning** — the project has no charter set.
- **Warning** — a record left in `hypothesized` with no human disposition.
- **Warning** — a record supersedes a predecessor that is not itself marked
  `superseded` (inconsistent lineage).

Exit code is `1` if any error-level issue exists, `0` otherwise. Run it after a
batch of edits and before relying on the records to guide work.
