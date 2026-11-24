---
name: forge
description: One-command runner for the full signal-forge chain - Extract (high-signal-data-architect) → Panel (get-more-perspectives) → Rebuild (reverse-engineer) - in a single pass. Use when the user types /forge, pastes or attaches one or more sources and asks to "run the chain", "forge this", "extract and rebuild", or wants messy docs, prompts or specs turned into one unified, cited system in one go.
---

# Forge: Run the Full Chain

Run all three signal-forge skills in order on the user's sources, handing each step's output to the next. Stop only at the one checkpoint below.

```
Sources → [S1: Extract] -> [S2: Panel] -> ? [Open questions] -> [S3: Rebuild] -> [S4: Deliver]
```

## Step 0: Intake

- Collect every source the user pasted or attached. If there are none, ask for them and stop.
- Assign fragment IDs (A, B, C… in the order received). Say in one line which ID goes with which source, so the user can trace the loci later.
- If only one source is given, still run the chain. The panel decides what to build around within that one source.

## Step 1: Extract

Read `${CLAUDE_PLUGIN_ROOT}/skills/high-signal-data-architect/SKILL.md` and follow it for each fragment. Use Default (Hybrid) mode. Prefix every locus with the fragment ID (`@FragA:P3`). Keep the cards; they are the input to Step 2. Skip that skill's closing offer to run the panel, since Forge runs it next anyway.

## Step 2: Panel

Read `${CLAUDE_PLUGIN_ROOT}/skills/get-more-perspectives/SKILL.md` and run it in **Chain Mode** on the cards. Produce the RECONSTRUCTION DIRECTIVE.

## Checkpoint: Open Questions

This is the only pause. Rulings are choices, not facts, so a split or declined vote should go back to the user rather than being guessed.

- If `open_questions` is empty, continue to Step 3 without stopping.
- If it has items, show the directive's open questions as a short numbered list, each with the panel's split, and ask the user to decide them (AskUserQuestion when available). Record each answer in the directive as `DECISION @user`.
- If the user says "skip" or doesn't answer, continue and leave those items as SURFACED CONFLICTS in Step 3.

## Step 3: Rebuild

Read `${CLAUDE_PLUGIN_ROOT}/skills/reverse-engineer/SKILL.md` and follow it, using the cards and the directive. Build around `primary_spine`; apply every ruling with its label intact.

## Step 4: Deliver

Present, in this order:

1. The Reverse-Engineer output (Executive Summary, Core Deliverable, Verification Checklist). This is the main result.
2. The RECONSTRUCTION DIRECTIVE, so the user can see which choices shaped the build.
3. The Extractor cards, collapsed under a heading like "Source cards" — they are the audit trail.

If the combined output is long or the user will keep it, save it as one file in addition to the chat reply.

## Rules That Hold Across All Steps

- Source facts carry `@Frag` loci. Panel choices carry `DECISION @panel (X–Y)`. User choices carry `DECISION @user`. Never let a decision lose its label or turn into a source fact.
- Nothing is invented at any step. A gap stays a gap until the panel or the user decides it, and then it is labeled as a decision.
- Do not stop between steps for approval except at the Checkpoint.
