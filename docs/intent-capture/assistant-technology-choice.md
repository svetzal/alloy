---
title: The Technology-Choice Assistant
summary: Starts from a stated technology choice and extracts the deeper capability it protects.
layer: leaf
parent: elicitation-assistants
tags: [elicitation, assistants, technology]
---

# The Technology-Choice Assistant

This mode starts from a stated choice and extracts the deeper intent. A
technology name is a means, not an end; the assistant asks what property the
developer is actually hiring that technology for.

## Example dialogue

Alloy:

> You said you intend to use PostgreSQL. What property are you hiring it for?

Possible follow-up choices:

- Transactional consistency.
- Mature operational tooling.
- Reporting flexibility.
- Relational modelling.
- JSONB pragmatism.
- Existing team familiarity.
- Avoiding operational complexity from multiple datastores.

## What the record should capture

The record should not merely say "use PostgreSQL." It should explain what
capability PostgreSQL protects and under what expectations that choice should be
revisited. That makes the resulting [[engineering-intent-record]] durable even
if the underlying technology is later swapped out.

See the other modes in [[elicitation-assistants]].

*Source: Product Brief §11.4 (The technology-choice assistant).*
