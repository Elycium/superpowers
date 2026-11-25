# evals

Regression cases for the Hyperarchetype harness. `diagnosing-superpowers` recommends a new case here
whenever it finds a mechanical gap.

- `hook-smoke.sh` pipes fake hook payloads into every `.claude/hooks/*.sh` script and checks the result,
  using a throwaway ledger so the real `.audit/ledger.jsonl` is untouched. It is the default
  `verify.commands` entry in `.claude/router.json`.
- `cases/*.json` describe behavioral expectations (which tier, which skill should or should not fire)
  for manual or scripted session evals.

Run: `bash evals/hook-smoke.sh`
