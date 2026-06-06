---
title: Contradiction Detection
summary: Recognizing when the code is correct but the intent is stale, and asking a human whether to simplify or preserve.
layer: leaf
parent: trace-feedback
tags: [feedback, contradiction, intent]
---

# Contradiction Detection

Sometimes the code is not wrong; the intent is outdated. An expectation that was reasonable when it was accepted may have become a stale assumption — and the abstraction built to honour it may now be slowing delivery.

This is a leaf under [[trace-feedback]].

## Worked example

```text
Intent:
  The payment provider will change frequently.

Observation:
  The same provider has been stable for 24 months and the abstraction is slowing delivery.

Assessment:
  Expectation may be stale.

Suggested action:
  Ask human whether to simplify or preserve abstraction.
```

## Resolving a contradiction

Because the question is whether the intent itself still holds, the suggested action is not an automatic repair. Alloy surfaces an [[assistant-contradiction]] and asks a human whether to **simplify** (retire the now-stale expectation and its abstraction) or **preserve** it. The decision then flows through [[record-lifecycle]] as the affected intent record is updated or deprecated.

Contrast this with [[drift-detection]], where the intent is still valid and it is the code that has drifted.

*Source: Integration Architecture §16.4.*
