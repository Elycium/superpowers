---
name: grill-with-docs
description: Use for Tier 3 architectural pillars, greenfield features, or high-risk changes before writing code. Pressure-tests requirements via one-by-one Socratic questioning, writes an approved spec to docs/specs/, and slices it into bounded task files for subagent dispatch.
---

# Grill With Docs (Hyperarchetype Requirements Gate)

## Purpose
Force unstated assumptions, edge cases, and architectural blind spots to the surface before implementation begins, leaving behind a durable spec and isolated task slices.

## Rules of Engagement
1. **One Question at a Time:** Ask a single, high-leverage question per turn. Wait for the answer before asking the next. Never dump a 10-question checklist.
2. **Codebase-First:** Read relevant files in `src/` and `docs/specs/` *before* asking. Never ask the user something you can verify directly from the repo.
3. **Challenge Vague Scope:** Probe explicitly for:
   - Exact files/modules in scope vs. off-limits (`CLAUDE.md` boundaries).
   - Failure modes, data integrity, and rollback/migration constraints.
   - Concrete, command-verifiable acceptance criteria for "done."
4. **Stop When Converged:** As soon as no material ambiguity remains (typically 3–7 questions), play back your complete understanding in a concise bulleted summary and ask for explicit sign-off.

## Required Artifacts (Upon Sign-Off)
1. **Write the Spec:** Create `docs/specs/<slug>.md` containing:
   - **Context & Goal**
   - **Decisions & Trade-offs** (referencing answers from the grilling session)
   - **Scope Boundaries** (allowed paths and explicit non-goals)
   - **Architecture & Contracts** (API routes, schemas, component boundaries)
   - **Edge Cases & Error Handling**
   - **Verification Criteria** (exact test commands that must pass)
2. **Slice into Bounded Tasks:** Break the spec into independent files under `docs/tasks/<slug>/task-01.md`, `task-02.md`, etc.
   - Each task file MUST be **<= 250 lines** (enforced by `.claude/hooks/guard-scope-and-leash.sh`).
   - Each task file MUST include: exact target file paths, acceptance criteria, and the recommended `.claude/router.json` model tier (`economy`, `mid`, or `frontier`).
3. **Handoff:** Present the spec path, task count, and model-tier breakdown. Do not write implementation code until the user approves execution.
