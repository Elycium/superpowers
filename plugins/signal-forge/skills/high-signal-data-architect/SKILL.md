---
name: high-signal-data-architect
description: Step 1 of the signal-forge chain. Turns mixed or narrative sources (system prompts, handbooks, API docs, papers, meeting notes) into standalone, executable extraction cards, one file per card, using a use-case template so the same source always yields the same cards. Every line carries a source locus and nothing is invented. Use whenever the user wants to extract, distill or convert a document into reusable rules, procedures, schemas or agent instructions, even if they just say "strip this down", "make this executable" or "turn this into cards".
---

# High Signal Architect-Extractor

Converts source text into **extraction cards**: small, self-contained units that each run on their own as a prompt or skill. Cards are modular. A later run, another chain or a person can pick up any single card and use it without the rest.

Read `card-format.md` (next to this file) before writing any card. It defines the header, body sections, card types, naming and the standalone rules. The format is fixed; do not add or drop sections.

## Core Principles

1. **Standalone and executable.** Each card works alone: it defines every term, field and threshold it uses, never points to another card, and reads as instructions a model can follow ("You are executing the card…").
2. **Imperative conversion.** Rewrite narrative into imperative steps, rules and formats.
3. **Aggressive signal-to-noise.** Keep actions, triggers, thresholds and units, invariants, negative constraints, roles, inputs/outputs, error recovery. Drop greetings, motivation, history, repetition and landscape text.
4. **Zero invention, full attribution.** Every Procedure step, Rule and Output line cites an exact `@locus`. A missing piece is written `Not specified in source.`
5. **Repeatable.** Same source + same template = same cards, same IDs, same order. Follow the template's split rules and the naming rules exactly; don't improvise structure.

## Symbolic Grammar

| Symbol | Meaning | Syntax Example |
|--------|---------|----------------|
| `->` | Sequence / Transition | `Step_A -> Step_B` |
| `+` | Concurrency | `Step_A + Step_B` |
| `&` | Conjunction / AND | `? [Check_A] & [Check_B]` |
| `\|` | Alternative / Branch | `Option_A \| Option_B` |
| `?` | Predicate / Decision | `? [Check Passed] -> Step_A` |
| `~>` | Asynchronous / Signal | `Trigger ~> Handler` |
| `<-` | Loop / Recursion | `? [Retry Condition] <- [S2: Reprocess]` (only when the source states iteration) |
| `( )` | Grouping | `(Step_A + Step_B) -> Step_C` |
| `param: type [constraints]` | Field Definition | `timeout_ms: int [range: 100-5000]` |
| `[ID: Action]` | Operational Node | `[S1: Ingest Data]` |
| `@locus` | Source Locus | `[S1: Ingest Data] @P1` |

## Use-Case Templates

Templates live in `templates/`. Each one says which card types a kind of source produces, how to split it, and how to cite it.

| Template | Source kinds |
|---|---|
| `system-prompt` | System prompts, agent instructions, personas, prompt libraries, rule files |
| `sop-handbook` | SOPs, handbooks, runbooks, playbooks, checklists, how-to guides |
| `api-spec` | API references, OpenAPI, data contracts, DB schemas, event specs, config references |
| `research-paper` | Papers, preprints, technical reports, methods and benchmark write-ups |
| `meeting-notes` | Meeting notes, transcripts, decision logs, threads, whiteboard photos |

**Choosing a template (one per fragment):**

1. If the user names a template, use it.
2. Otherwise read the "Pick this template when" list in each template and choose the first one, in the table order above, whose signals the fragment matches.
3. If none fits, use `sop-handbook` for prose written for people and `system-prompt` for prose written for a model, and say so in the summary.

State the choice per fragment in one line: `Fragment A → sop-handbook`.

## Execution Protocol

1. **Intake.** Assign fragment IDs (A, B, C… in the order received) and declare the `universe_of_truth`: what is in scope and what is excluded.
2. **Template.** Pick one template per fragment (above). Read that template file.
3. **Locus map.** Number the source using the template's locus convention. Prefer the source's own structure; fall back to `P1`, `P2`. Never invent line numbers.
4. **Plan the cards.** Walk the source in order. Using the template's "Read the source for" table and split rules, list each card as `card_id · card_type · title · first locus`. This list is the card index.
5. **Write each card** in the `card-format.md` shape: header, then body sections in order. Copy in every definition the card depends on. Numbers, units, names and negative constraints stay verbatim.
6. **Audit each card** against the five standalone rules in `card-format.md` and its own Self-check. Fix any card that fails before moving on.
7. **Deliver** (below).

## Output

**Where files can be written** (Claude Code, Cowork): write each card to `forge-output/<run-slug>/cards/<card_id>.md`, plus `forge-output/<run-slug>/cards/INDEX.md` containing:

```markdown
# Card index: <run title>
| card_id | type | title | template | first locus |
|---|---|---|---|---|
```

`<run-slug>` is the run title in kebab-case plus today's date (`onboarding-merge-2026-11-24`). If the folder exists, reuse it: overwrite cards whose content changed (bumping `version`) and leave identical cards untouched.

**In chat only:** print the index table, then every card in full, each inside its own fenced ```markdown block so it can be copied as one unit.

Either way, end with a short summary: fragments and templates used, number of cards by type, any `question` cards, and anything in scope that was skipped.

### Symbolic Strict mode (on request)

If the user asks for a pure operational spec instead of cards, emit: Executive Summary, then `[SCHEMA]`, `[PIPELINE]`, `[POLICY]`, `[FALLBACK]` sections in the grammar above with a locus on every item, then a Verification Checklist. Cards remain the default.

## Negative Constraints

- Do not add rules, fields, steps or parameters absent from the source.
- Do not expand beyond the universe of truth.
- Do not reference one card from another, even to save space.
- Do not keep landscape or motivational paragraphs.
- If the source yields no extractable signal, emit only a summary stating zero cards.

## Handoff (signal-forge chain)

Cards → `get-more-perspectives` (the panel decides what to build around, citing card IDs) → `reverse-engineer` (rebuilds one system from the cards). Keep `card_id`s and `@Frag` loci intact; downstream steps depend on them. When the user has more than one source or asks to rebuild or reconcile, end by offering the panel step.
