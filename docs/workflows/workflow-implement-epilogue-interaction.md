---
title: Implement an Epilogue Interaction
summary: Workflow C — take an Epilogue interaction, compile a formation brief, and run it through Foundry against engineering intent.
layer: leaf
parent: workflows
tags: [workflow, epilogue, formation, foundry]
---

# Workflow C: Implement Epilogue interaction with engineering intent

This workflow connects product-level interactions to engineering work. It begins with an interaction from the [[alloy-and-epilogue-tracker|Epilogue Tracker]], compiles a [[formation-brief|formation brief]] and [[prompt-pack|prompt packs]], runs through Foundry, and ingests the result as [[trace-feedback|trace feedback]].

1. User selects an Epilogue interaction.
2. Alloy retrieves related engineering intent.
3. Alloy asks for clarification if needed.
4. Alloy creates a formation brief.
5. Alloy compiles prompt packs and evidence plan.
6. Foundry runs dry-run first, then full if permitted.
7. Foundry executes the selected formation.
8. Alloy ingests the trace.
9. Alloy updates evidence and reports intent satisfaction.

See also the other [[workflows]] and the runtime view in [[end-to-end-flows]].

*Source: Product Brief §22 (Primary Product Workflows), Workflow C.*
