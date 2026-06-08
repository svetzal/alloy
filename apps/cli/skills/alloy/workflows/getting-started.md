# Getting Started with Alloy

Bootstrapping Alloy in a project. Assumes the `alloy` binary is installed; see
the Setup section of `../SKILL.md` for the model and conventions.

## Step 1: Configure `.alloy_env`

If there is no `.alloy_env` in the project root, direct the user to:

1. **Open** the Alloy web console (`ALLOY_API_HOST`, e.g.
   `https://alloy.example.com`).
2. **Log in** and find or create the **project** that corresponds to this
   codebase.
3. **Generate a token** (Projects → the project → Generate token). The console
   shows a ready-to-paste `.alloy_env` snippet once — copy it immediately.
4. **Save** it as `.alloy_env` in the project root (where you will run `alloy`).

```
ALLOY_API_HOST=https://alloy.example.com
ALLOY_API_TOKEN=alloy_…
```

Add `.alloy_env` to the project's `.gitignore` — it holds a secret and must
never be committed.

## Step 2: Install the skill files

```bash
alloy init
```

This writes the Alloy skill into `.claude/skills/alloy/` so coding assistants in
this repo understand the intent model and the CLI. Re-run after upgrading the
`alloy` binary. Use `alloy init --global` to install once for all your projects.

## Step 3: Verify the connection and read the charter

```bash
alloy charter show --json
```

- **All-`null` fields:** the project has no charter yet. Establish it (Step 4).
- **Populated:** read it — it tells you what capabilities matter here.
- **Error:** check that `.alloy_env` exists and you are in the project root.

```bash
alloy intent list --json
```

- **Empty array:** a fresh project. Start capturing intent (Step 5).
- **Records present:** review them before adding more, to avoid duplicating or
  contradicting existing judgements.

## Step 4: Establish the charter (if unset)

The charter grounds every record. Set the fields you can answer; leave the rest
for later (`charter set` is a partial upsert).

```bash
alloy charter set \
  --mission "What this product is for" \
  --target-audience "Who it serves" \
  --problem-space "The problem it addresses" \
  --differentiators "What sets it apart" \
  --out-of-scope "What it deliberately does not do" \
  --json
```

The **out-of-scope** field is the one most worth filling in early: it lets you
reject intent that does not belong in this product.

## Step 5: Capture the first records

Walk the codebase (or the user's reasoning) for judgements worth preserving —
boundaries, seams, error contracts, deliberate constraints. For each, apply the
first question: *what capability is lost, under what pressure, if this reasoning
is forgotten?* Then create a record (see
[capturing-intent.md](capturing-intent.md) for the full method):

```bash
alloy intent create --title "…" --capability "…" --threat "…" \
  --expectation "…" --strategy "…" --evidence-summary "…" --tradeoff "…" --json
```

Records extracted from existing code should usually start `hypothesized` (the
default `proposed` is fine for judgements the user states directly). Let a human
`accept` them before they guide work.

## Step 6: Generate agent docs and validate

```bash
alloy docs --agents --output AGENTS-alloy.md
alloy validate --json
```

`docs --agents` produces project-specific guidance (with the live charter) for
other agents working in the repo. `validate` confirms the records hang together.
