---
name: forge
description: One-command runner for the full signal-forge chain - Extract (high-signal-data-architect, standalone extraction cards) → Panel (get-more-perspectives) → Rebuild (reverse-engineer) - in a single pass, saving the cards, directive, result and an HTML report. Use when the user types /forge, pastes or attaches one or more sources and asks to "run the chain", "forge this", "extract and rebuild", or wants messy docs, prompts or specs turned into reusable cards and one unified, cited system.
---

# Forge: Run the Full Chain

Run all three signal-forge skills in order on the user's sources, handing each step's output to the next. Everything runs inside this conversation: no API key, no external service. Stop only at the one checkpoint below.

```
Sources → [S0: Intake] -> [S1: Extract cards] -> [S2: Panel] -> ? [Open questions] -> [S3: Rebuild] -> [S4: Report]
```

## Where output goes

If you can write files (Claude Code, Cowork), everything for a run goes in one folder:

```
forge-output/<run-slug>/
  run.json        title, date, fragments, templates, your decisions
  cards/          one standalone card per file + INDEX.md
  directive.md    panel review + RECONSTRUCTION DIRECTIVE
  result.md       the rebuilt system
  report.html     everything above as one page with tabs
```

`<run-slug>` = the run title in kebab-case plus today's date, e.g. `onboarding-merge-2026-11-24`. Ask for a title only if the user gave none and the sources don't suggest one; otherwise derive it.

If you can't write files (plain chat), give the same content in chat in the Step 4 order.

## Step 0: Intake

- Collect every source the user pasted or attached. If there are none, ask for them and stop.
- Assign fragment IDs (A, B, C… in the order received) and pick a template per fragment (rules in the extractor skill). Say in one line per fragment which ID, source and template go together, so the user can trace loci later and correct a template choice.
- If only one source is given, still run the chain. The panel decides what to build around within that one source.

## Step 1: Extract

Read `../high-signal-data-architect/SKILL.md`, its `card-format.md` and the chosen `templates/*.md`, and follow them. Write the cards and `cards/INDEX.md`. Skip that skill's closing offer to run the panel, since Forge runs it next.

Every card must pass the standalone rules before Step 2.

## Step 2: Panel

Read `../get-more-perspectives/SKILL.md` and run it in **Chain Mode** on the cards. Save the review and the RECONSTRUCTION DIRECTIVE to `directive.md`.

## Checkpoint: Open Questions

This is the only pause. Rulings are choices, not facts, so a split or declined vote goes back to the user rather than being guessed.

- If `open_questions` is empty, continue to Step 3 without stopping.
- Otherwise ask the user to decide each one, showing the question, the cards involved and the panel's split. Use AskUserQuestion when available, with each question's `options` as the choices (the user can still type their own answer). Otherwise ask in one numbered message.
- Record each answer as `DECISION @user` in `directive.md` (append a `## User decisions` section) and in `run.json` `decisions`.
- If the user says "skip" or doesn't answer, continue and record those questions with `"answer": null`. They become SURFACED CONFLICTS in Step 3.

## Step 3: Rebuild

Read `../reverse-engineer/SKILL.md` and follow it, using the cards and the directive. Build around `primary_spine`; apply every ruling and user decision with its label intact; leave out `excluded_cards`. Save the output to `result.md`, using these headings so the report can find them: `## Executive Summary`, `## Core Deliverable` (with `### PRIMARY PIPELINE`, `### COMPONENT ATTRIBUTION`, `### SURFACED CONFLICTS`, `### GAPS & MISSING LINKS`), `## Verification Checklist`.

## Step 4: Report and deliver

1. Write `run.json`:

```json
{
  "title": "Onboarding merge",
  "date": "2026-11-24",
  "fragments": [{"id": "A", "name": "Prompt v1.md", "template": "system-prompt"}],
  "decisions": [{"question": "Which file limit applies?", "answer": "20 (A)"}],
  "models": ""
}
```

2. Build the report by running `python3 <this skill's folder>/build_report.py forge-output/<run-slug>`. It only reads the run folder and writes `report.html`; it makes no network calls. If Python isn't available, copy `report-template.html` to `report.html` yourself and replace `/*FORGE_DATA*/` with the same JSON the script builds (see the script's docstring), writing `<\/` for every `</` inside it.

3. Tell the user, in this order:
   1. The Executive Summary (2 sentences) and the counts: cards by type, conflicts, gaps.
   2. Links to `report.html` and the `cards/` folder. Point out that each card can be reused on its own: paste it into any Claude conversation or save it as a skill.
   3. Which choices shaped the build: the primary spine and any `@user` decisions.

## Rules That Hold Across All Steps

- Source facts carry `@Frag` loci. Panel choices carry `DECISION @panel (X–Y)`. User choices carry `DECISION @user`. Never let a decision lose its label or turn into a source fact.
- Cards are never edited to apply a ruling. They stay exactly as extracted, so they can be reused in other runs.
- Nothing is invented at any step. A gap stays a gap until the panel or the user decides it, and then it is labeled as a decision.
- Do not stop between steps for approval except at the Checkpoint.
