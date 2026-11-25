# CLAUDE.md — Hyperarchetype Kernel

This fork is a personal Claude Code harness on top of Superpowers. `AGENTS.md` still governs
upstream contribution rules. This file decides how much process each request gets.

## Classify first, then act

| Tier | What it looks like | Process | Router tier |
|------|--------------------|---------|-------------|
| **1 · Surgical** | One file, a few lines, intent is unambiguous (typo, rename, config value, small fix) | **No skills.** Edit, verify, done. Do not brainstorm or plan. | `economy` |
| **2 · Standard** | One skill, hook or module; behavior is clear but touches several lines or files | Short inline plan (3–5 bullets), then `test-driven-development` where tests exist. | `mid` |
| **3 · Architectural** | New capability, cross-skill or cross-harness change, schema or contract change, anything hard to roll back | **Run `grill-with-docs` before any code.** Spec in `docs/specs/<slug>.md`, tasks in `docs/tasks/<slug>/task-NN.md`, wait for approval. | `frontier` to plan, task tier to execute |

When unsure between two tiers, pick the higher one and say so in one line.

## Boundaries

- Allowed and protected paths live in `.claude/router.json` → `scope`. `guard-scope-and-leash.sh` enforces them.
- `.claude/router.json`, `.claude/settings.json` and `.claude/hooks/` are human-edited only.
- While `.audit/active-task` names a task file, edit only that task's `## Target Files` (plus `docs/` and `evals/`).
- Task files stay at or under 250 lines. Subagents per session are capped by `max_subagents_per_session`.

## Done means verified

- `verify-before-complete.sh` runs `verify.commands` on Stop when watched paths changed. Do not claim done while it fails.
- After 3 failed edit/test loops on the same problem, switch to `systematic-debugging`.

## When the harness misbehaves

Use `diagnosing-superpowers`. Evidence lives in `.audit/ledger.jsonl` (gitignored, one JSON event per line, keyed by `session_id`).
