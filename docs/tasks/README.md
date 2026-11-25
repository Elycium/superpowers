# docs/tasks

Bounded task slices cut from a spec: `docs/tasks/<slug>/task-NN.md`.

- Each file is at most **250 lines**. `.claude/hooks/guard-scope-and-leash.sh` blocks any Write or Edit that would go over.
- Each file lists its exact target paths under `## Target Files` as backticked paths. When `.audit/active-task`
  holds a task file's path, the guard only allows edits to those targets (plus `docs/` and `evals/`).
- Each file names its `.claude/router.json` tier: `economy`, `mid` or `frontier`.

Start from `_template.md`. To activate a task: `echo docs/tasks/<slug>/task-01.md > .audit/active-task`.
Clear it with `rm .audit/active-task`.
