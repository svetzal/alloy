# Capturing Intent: Turning a Judgement into a Record

How to take a piece of engineering reasoning — stated by a person, or inferred
from code — and turn it into a well-formed Engineering Intent Record. For the
field definitions, see [../references/intent-model.md](../references/intent-model.md).

## The test: is there intent to capture?

Before creating a record, ask the **first question**:

> What capability would be lost, and under what future pressure, if no one knew
> this reasoning?

If you can name a **capability** and a **threat**, there is intent worth
recording. If you cannot, you have a task, a note, or a preference — not an
intent record. Reformatting, renames, typo fixes, and routine dependency bumps
usually have no preservable intent. Boundaries, seams, error contracts, and
deliberate constraints usually do.

## Filling the six fields

Work the fields in the order of the sentence — each one constrains the next.

1. **Capability.** State the ability to *retain*, as an outcome, not a mechanism.
   "Business rules can be tested without a database" — not "we use a functional
   core." The mechanism is the strategy; keep it out of the capability.
2. **Threat.** Name the specific force that erodes the capability. Concrete and
   observable: "logic leaking into LiveView handlers," not "bad architecture."
3. **Expectation.** Say why the threat matters *now* — the future change or
   pressure. Without this, the record reads as preference. "Agents will change
   the web layer frequently" makes the threat urgent.
4. **Strategy.** Now name the approach that protects the capability against the
   threat. This is where mechanisms belong.
5. **Evidence.** State what you can *look at* to confirm the strategy is holding.
   Prefer things a gate or a test can check over things only a human can judge.
6. **Tradeoff.** Name the cost honestly. If you cannot think of one, the record
   is probably dogma — reconsider whether it is a real judgement. The tradeoff is
   what lets a future reader re-weigh the decision.

### Read it back

A finished record should read as the canonical sentence:

> We need to preserve **[capability]** because **[threat]** matters under
> **[expectation]**, so we prefer **[strategy]**, require **[evidence]**, and
> accept **[tradeoff]**.

If the sentence does not hold together, a field is misplaced — most often a
mechanism sitting in the capability slot, or a missing expectation.

## Worked example

A reviewer says: "Don't let the Stripe SDK types into the domain — we'll
probably switch processors."

```bash
alloy intent create \
  --title "Keep payment provider replaceable" \
  --capability "Payment providers can be swapped without rewriting domain logic" \
  --threat "Vendor SDK types spreading from adapters into domain modules" \
  --expectation "The payment processor is likely to change within a year" \
  --strategy "A PaymentGateway behaviour; SDK types confined to the adapter" \
  --evidence-summary "Stripe imports appear only in the adapter module" \
  --tradeoff "An extra mapping layer between SDK and domain types" \
  --json
```

The slug derives to `keep-payment-provider-replaceable`. It starts `proposed`.

## Set the right starting status and confidence

- A judgement the **user states directly** → leave the default `proposed`, or
  `accept` it immediately if they have the authority and intent to commit.
- Intent **inferred from code** (archaeology) → create with
  `--status hypothesized` and a lower `--confidence`; surface it for human
  confirmation rather than treating it as settled.

```bash
alloy intent create --title "…" --status hypothesized --confidence 0.4 … --json
```

## Refining versus refuting

When an existing record needs to change:

- **Refine** (clearer scope, better evidence, shifted strategy) → create the new
  record, then `supersede` the old one and link the replacement:
  ```bash
  alloy intent supersede old-slug --by new-slug --json
  ```
- **Refute** (the reasoning turned out to be wrong) → `contradict` it:
  ```bash
  alloy intent contradict old-slug --json
  ```

Both are terminal, preserving the history rather than deleting it. Reach for
`remove` only for records created in error that never carried real intent.

## After capturing

Run `alloy validate --json` to confirm slugs are well-formed, supersede links
resolve, and nothing is left dangling. Then, if other agents work in the repo,
regenerate `alloy docs --agents` so the new intent is reflected in their
guidance.
