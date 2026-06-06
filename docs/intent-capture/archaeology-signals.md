---
title: Archaeology Signal Categories
summary: The five categories of evidence Alloy reads to form intent hypotheses from a codebase.
layer: leaf
parent: codebase-archaeology
tags: [archaeology, signals, evidence]
---

# Archaeology Signal Categories

When performing [[codebase-archaeology]], Alloy reads five categories of signal.
Each category surfaces a different kind of evidence about why a codebase is
shaped the way it is.

## Structural signals

These come from code shape.

- Gateways, repositories, adapters, ports, behaviours, protocols, interfaces.
- Domain modules separated from UI or framework modules.
- Typed errors and result types.
- Contract tests.
- Architecture boundary scripts.
- Test fakes and fixtures.
- Explicit module naming conventions.
- Dependency direction.

## Behavioural signals

These come from how code changes.

- Frequent refactoring in a module.
- High test churn around a boundary.
- Repeated changes to integration code.
- CI failures clustered around a specific gate.
- Agent retries repeatedly caused by the same architectural violation.

## Historical signals

These come from Git history, commits, PRs, ADRs, issues, and release notes.

- A gateway introduced immediately after several vendor API changes.
- A boundary check added after repeated violations.
- Commit messages mentioning "decouple", "isolate", "stabilize", "extract",
  "make testable", or "remove framework dependency".
- ADRs that explain decisions but not the underlying capability being protected.

## Textual signals

These come from docs and conversation.

- `CHARTER.md`.
- `AGENTS.md`.
- README architecture sections.
- PR comments.
- Code review comments.
- Team chat transcripts.
- Meeting notes.

## Evidence signals

These come from gates, tests, and validation tooling.

- `.hone-gates.json` gates.
- Static import checks.
- Test suite organization.
- Contract test commands.
- Architecture linting.
- Foundry validation and trace outcomes.

These signals become the `observed` list in a [[hypothesis-format|hypothesis]],
and many of them double as candidates for [[evidence-and-gates]].

*Source: Product Brief §12 (Signal categories).*
