---
title: Open Questions
summary: Unresolved design decisions drawn from both the Product Brief and the Integration Architecture.
layer: leaf
parent: reference
tags: [open-questions, design, decisions]
---

# Open Questions

These questions remain open. They are grouped by their source document and kept
faithful to the original wording. Up to [[reference]].

## From the Product Brief

1. Should the canonical store be centralized PostgreSQL from the beginning, or
   should the first version also support local repo-based records?
2. How should Alloy authenticate with Epilogue Tracker and Foundry? (See
   [[security-and-authority]].)
3. What is the minimum useful bridge between Phoenix/LiveView Alloy and Rust
   Foundry before native Foundry changes are warranted?
4. Should [[formation-brief|Formation Briefs]] be signed in the MVP, or is
   digest verification enough?
5. Should accepted intent records require an owner?
6. How should intent exceptions be represented?
7. What is the minimum useful evidence model?
8. Should Alloy generate `.hone-gates.json` overlays or propose edits for human
   approval?
9. How much Foundry integration should happen before the composition layer is
   extracted?
10. Should codebase archaeology inspect Git history in the MVP, or start with
    static structure only?
11. How should multiple conflicting intent records be resolved during prompt
    compilation?
12. How should product/design/engineering intent conflicts be surfaced?
13. Which agent provider should be assumed for the MVP, if any?
14. Should Alloy maintain local projections such as `CHARTER.md`, or should
    Foundry query Alloy directly?
15. How should Alloy prevent intent records from becoming organizational
    dogma?
16. Should the first runner be an Alloy CLI, an Elixir process, a Rust helper,
    or a Foundry subcommand?

## From the Integration Architecture

1. What is the minimum useful bridge before native Foundry changes are warranted?
2. Should the first runner be a separate process, a Foundry subcommand, or an
   Alloy CLI command?
3. Should Alloy store raw Foundry traces or only normalized summaries?
4. Should [[formation-brief|Formation Briefs]] be signed in the MVP, or is
   digest verification enough?
5. What is the first useful Gate Overlay format for Foundry to consume?
6. Should prompt packs be stored as database records, files, or both?
7. How much source code content should Alloy store after archaeology?
8. Should runner credentials be project-scoped, organization-scoped, or both?
   (See [[security-and-authority]].)
9. How should branch policies differ between dry-run, full mutation, commit,
   and push? (See [[integration-modes]].)
10. What is the first concrete Foundry task block that should become
    Alloy-aware?
11. Should Alloy compile Foundry composition configuration only after Foundry
    extracts composition from Rust code?
12. How should Alloy handle conflicts between product intent from Epilogue and
    engineering intent from Alloy?
13. What trace summary is sufficient for intent feedback without importing huge
    raw traces?
14. How should Alloy represent a strategy that was correct but too expensive?
15. What authorization is required for an agent to weaken, remove, or rewrite
    evidence?

*Source: Product Brief §30 (Open Questions); Integration Architecture §24 (Open Questions).*
