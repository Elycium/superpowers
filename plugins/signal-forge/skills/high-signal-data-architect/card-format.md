# Extraction Card Format (v1)

An extraction card is one self-contained, executable unit pulled from a source. "Executable" means the card body works on its own as a prompt or skill: paste it into any Claude session (or save it as a `SKILL.md`) and it runs, with no other card, source or conversation needed.

One card = one file. File name: `<card_id>.md`.

## Header (YAML front matter)

```yaml
---
card_id: A-procedure-refund-request        # <frag>-<card_type>-<slug>; see Naming
card_type: procedure                       # one of the types below
template: sop-handbook                     # the use-case template that produced it
title: Handle a refund request
version: 1                                 # bump only when the content changes on a re-run
source:
  fragment: A
  name: Support handbook 2026.pdf
  loci: ["@FragA:§4.2", "@FragA:§4.3"]     # every locus the body cites
tags: [support, refunds]                   # 1-5, lower-case, from the source's own vocabulary
inputs:                                    # what the card needs when run
  - name: request
    type: text
    required: true
outputs:                                   # what running the card produces
  - name: decision
    type: "approve | deny | escalate"
standalone: true                           # always true; see Standalone rules
---
```

All keys are required. `inputs` may be empty only for `role` and `policy` cards that apply to a whole conversation.

## Body (Markdown, in this order)

```markdown
# <title>

You are executing the card "<title>" (<card_id>). Follow it exactly.

## Purpose
One sentence: what this card makes happen. @locus

## When to run
The trigger or condition, from the source. @locus

## Inputs
- `request` (text, required): <what it is>. @locus

## Procedure
1. <Imperative step>. @locus
2. ? [<condition>] -> <step> | <other step>. @locus

## Rules
- MUST / NEVER <constraint, numbers and units verbatim>. @locus

## Output
The exact format the card returns (a template, a schema or an example from the source). @locus

## If something fails
- ? [<failure>] -> <recovery>. @locus
(Write "Not specified in source." if the source gives none.)

## Do not overread
What the source does NOT say, so the runner doesn't invent it.

## Self-check
- [ ] <observable check that the output satisfies the Rules and Output sections>
```

Sections with nothing from the source keep their heading and say `Not specified in source.` Never fill them by inference.

## Card types

| card_type | Use for | Must contain |
|---|---|---|
| `role` | A persona, mandate or agent identity | Purpose, Rules, Output (voice/format) |
| `procedure` | A sequence of steps someone or something performs | Inputs, Procedure (≥2 steps), Output |
| `schema` | A data shape, record, payload or form | Output = the field table: `name · type · required · constraints · @locus` |
| `policy` | Standing rules that constrain other work | Rules (≥1 MUST/NEVER), When to run |
| `decision` | A choice that was made, with its rationale | Purpose = the decision, Rules = what it binds, Output = what changes |
| `action` | A task assigned to someone | Inputs, Procedure, Output = done-condition; owner and due date in Rules if given |
| `method` | An algorithm, technique or experimental method | Procedure, Rules (parameters verbatim), Output |
| `evaluation` | How to measure or test something | Procedure (how to measure), Output (metric + threshold) |
| `fallback` | Error handling, escalation or recovery | When to run (the failure), Procedure (the recovery) |
| `question` | An open issue the source raises but doesn't settle | Purpose = the question, Output = what an answer must contain; never answer it |

## Naming (makes re-runs repeatable)

- `card_id` = `<fragment letter>-<card_type>-<slug>`, all lower-case except the fragment letter.
- `slug` = 2–5 words taken from the source's own heading or the first noun phrase of the item, kebab-case. Do not paraphrase. If two cards collide, append `-2`, `-3` in source order.
- Cards are numbered and written in the order their first locus appears in the source.

The same source with the same template must give the same card IDs on every run.

## Standalone rules

A card fails if any of these are true:

1. It mentions another card, "above", "below", "see section X" or "as defined elsewhere".
2. It uses a term, field, role or threshold that the card itself doesn't define. Copy the definition in (with its locus) instead of pointing to it. Duplication across cards is expected.
3. A Procedure step or Rule has no `@locus`.
4. It contains anything not in the source. A gap stays `Not specified in source.`
5. Running it needs information outside its own Inputs.

## Shared notation

Same grammar as the rest of the chain: `[S1: Action] @FragA:P2`, `->` sequence, `+` concurrency, `?` decision, `|` branch, `<-` loop only when the source states iteration. Loci: `@FragA:§3.2`, `@FragA:P4`, `@FragA:p12` (PDF page), `@FragC:P1` (visual block of an image).
