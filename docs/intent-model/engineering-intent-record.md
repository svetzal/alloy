---
title: The Engineering Intent Record
summary: An Engineering Intent Record holds six fields — Capability, Threat, Expectation, Strategy, Evidence, and Tradeoff — that together express a contextual engineering judgement.
layer: leaf
parent: engineering-intent
tags: [intent, record, fields, schema]
---

# The Engineering Intent Record

An Engineering Intent Record expresses a future-facing engineering judgement:

> We need to preserve this capability because this threat matters under this
> expectation, so we prefer this strategy, require this evidence, and accept
> this tradeoff.

The judgement is decomposed into six fields. Each field carries one part of the
reasoning, and together they keep the decision specific and checkable.

## Fields

### Capability

The ability the system or team must retain.

Examples:

- Business rules can be tested without UI, network, or database dependencies.
- External service providers can be replaced without rewriting domain logic.
- Failure semantics remain stable for consumers.
- Product interactions can be implemented without introducing cross-module
  coupling.
- The system can be deployed safely after small changes.

### Threat

The force that erodes the capability.

Examples:

- Business logic leaking into UI event handlers.
- Vendor SDK types spreading into domain modules.
- Ad hoc string errors escaping into API responses.
- SQL queries scattered through application code.
- Tests coupled to implementation details.
- Agent-generated code bypassing existing boundaries.

### Expectation

The future change, uncertainty, or pressure that makes the threat matter.

Examples:

- Payment providers are likely to change.
- UI flows will evolve faster than domain policy.
- Reporting requirements will expand.
- More consumers will integrate with this API.
- The team expects autonomous agents to make frequent changes.

### Strategy

The technical or social approach used to protect the capability.

Examples:

- Functional Core / Imperative Shell.
- Gateway abstractions.
- Typed domain errors.
- Four Rules of Simple Design.
- Contract tests.
- Architecture import-boundary checks.
- Thin LiveView handlers delegating to domain services.

### Evidence

Observable proof that the strategy is working.

Examples:

- Domain tests run without a database.
- Vendor SDK imports only appear in adapter modules.
- Error responses are generated from typed domain errors.
- A gate enforces import boundaries.
- Foundry traces show retries only addressed failed gates rather than broadening
  the solution.
- PR review confirms intent records were preserved.

### Tradeoff

The cost, downside, or failure mode introduced by the strategy.

Examples:

- Gateway abstractions can become ceremony if volatility is low.
- Functional core boundaries can be over-applied to simple CRUD.
- Strongly typed errors require additional mapping layers.
- Import-boundary gates can annoy developers if the boundaries are unclear.

The tradeoff field is not optional polish — see [[why-tradeoffs-matter]] for why
it is what keeps records useful. For complete records drawn from real projects,
see [[example-intent-records]].

## Minimal Engineering Intent Record JSON Shape

```json
{
  "id": "alloy.intent.example",
  "title": "Example engineering intent",
  "status": "proposed",
  "scope": {
    "project": "example-project",
    "paths": []
  },
  "capability": "Capability to preserve",
  "threat": "Threat that erodes the capability",
  "expectation": "Future change or pressure that makes this matter",
  "strategy": "Preferred approach",
  "evidence": [
    {
      "type": "gate",
      "description": "Observable proof",
      "required": true
    }
  ],
  "tradeoff": "Cost or failure mode of the strategy",
  "sources": [],
  "confidence": 1.0,
  "created_at": "2026-06-06T00:00:00-04:00",
  "updated_at": "2026-06-06T00:00:00-04:00"
}
```

## Up

- [[engineering-intent]] — section overview.

*Source: Product Brief §9 (Fields) and Appendix B (Minimal Engineering Intent Record JSON Shape).*
