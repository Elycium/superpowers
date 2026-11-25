---
name: diagnosing-superpowers
description: Use when a session misbehaves — a skill fired when it shouldn't, stayed silent when it should, the agent ignored its plan, repeated work, hit a hook block, or burned unexpected tokens. Audits transcripts and .audit/ledger.jsonl with line-level evidence and optionally exports a scrubbed bug bundle.
---

# Diagnosing Superpowers (Hyperarchetype Forensics)

## Purpose
Investigate session failures using hard evidence from transcripts, hook blocks, and `.audit/ledger.jsonl`—never speculation.

## Forensic Workflow
1. **Identify Target Session:**
   - Default to the current session unless the user names a specific session ID.
   - Locate the session transcript and filter `.audit/ledger.jsonl` by `session_id`.
2. **Audit Against Four Failure Classes:**
   - **Skill & Bootstrap Drift:** Did `session-bootstrap.sh` fire on `startup` and `compact`? Did a skill fire on a Tier 1 surgical edit, or stay silent on a Tier 3 task?
   - **Plan & Scope Deviation:** Did the agent modify files outside `docs/tasks/<slug>/task-NN.md` or ignore the approved `docs/specs/<slug>.md`?
   - **Leash & Routing Anomalies:** Check `.audit/ledger.jsonl` for:
     - Subagent fan-out approaching or hitting `.claude/router.json` `max_subagents_per_session`.
     - Tasks routed to `frontier` that belonged on `mid` or `economy`.
     - Blocked calls from `guard-scope-and-leash.sh` or `verify-before-complete.sh`.
   - **Rework & Token Burn:** Flag repeated edit/test loops (>3 attempts without invoking `systematic-debugging`) or oversized context reads.
3. **Report with Line-Level Evidence:**
   - Emit a concise timeline citing exact turn/line numbers from the transcript and exact timestamps/entries from `.audit/ledger.jsonl`.
   - Separate **Root Cause** (mechanical hook gap, stale skill rule, or model drift) from **Recommended Fix** (exact edit to `CLAUDE.md`, `.claude/router.json`, a hook script, or an eval case in `evals/`).
4. **Optional Scrubbed Bundle:**
   - If the user requests a bug report, package the relevant transcript excerpt, filtered `.audit/ledger.jsonl` lines, and `.claude/router.json` into `/tmp/hyperarchetype-bug-<session_id>.tar.gz`, scrubbing secrets, API keys, and proprietary code paths before writing.
