#!/usr/bin/env bash
# Smoke test for .claude/hooks: syntax, JSON configs, and behavior on fake payloads.
# Runs against a throwaway project dir so the real .audit/ledger.jsonl is untouched.
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS="$REPO/.claude/hooks"
pass=0
fail=0
ok() { pass=$((pass + 1)); echo "  ok   $1"; }
bad() { fail=$((fail + 1)); echo "  FAIL $1"; }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }

command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }

echo "syntax"
for f in "$HOOKS"/*.sh "$REPO/evals/hook-smoke.sh"; do
  check "bash -n $(basename "$f")" "bash -n '$f'"
done
check "jq .claude/settings.json" "jq -e . '$REPO/.claude/settings.json' >/dev/null"
check "jq .claude/router.json" "jq -e . '$REPO/.claude/router.json' >/dev/null"

# Throwaway project with the real router, but safe verify commands.
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/.claude" "$T/docs/tasks/demo" "$T/skills/demo"
jq '.verify.commands = ["test ! -f FAIL_MARKER"] | .verify.watch_paths = ["skills/"]' \
  "$REPO/.claude/router.json" >"$T/.claude/router.json"
export CLAUDE_PROJECT_DIR="$T"
L="$T/.audit/ledger.jsonl"
run() { local hook="$1" payload="$2"; printf '%s' "$payload" | bash "$HOOKS/$hook" >"$T/out" 2>"$T/err"; echo $?; }
write() { jq -nc --arg sid "$1" --arg fp "$2" --arg c "$3" '{session_id:$sid,tool_name:"Write",tool_input:{file_path:$fp,content:$c}}'; }
nlines() { seq 1 "$1" | sed 's/^/line /'; }

# expect <name> <want-exit> <hook> <payload>
expect() {
  local got
  got="$(run "$3" "$4")"
  if [ "$got" = "$2" ]; then ok "$1"; else bad "$1 (exit $got, want $2)"; fi
}
# expect_json <name> <jq-test> <file>
expect_json() { if jq -e "$2" "$3" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }
empty_out() { if [ ! -s "$T/out" ]; then ok "$1"; else bad "$1 (got: $(cat "$T/out"))"; fi; }

echo "session-bootstrap"
expect "startup exits 0" 0 session-bootstrap.sh '{"session_id":"s1","source":"startup"}'
expect_json "emits additionalContext" '.hookSpecificOutput.additionalContext | test("Tier 1")' "$T/out"
run session-bootstrap.sh '{"session_id":"s1","source":"compact"}' >/dev/null
check "startup and compact logged with session_id" \
  "jq -se 'map(select(.event==\"SessionStart\" and .session_id==\"s1\")) | length == 2' '$L' >/dev/null"

echo "guard-scope-and-leash"
expect "allowed path passes" 0 guard-scope-and-leash.sh "$(write s1 "$T/skills/demo/SKILL.md" hi)"
expect "path outside allowed_paths blocked" 2 guard-scope-and-leash.sh "$(write s1 "$T/random.txt" hi)"
expect "protected router.json blocked" 2 guard-scope-and-leash.sh "$(write s1 "$T/.claude/router.json" '{}')"
expect "protected hooks dir blocked" 2 guard-scope-and-leash.sh "$(write s1 "$T/.claude/hooks/x.sh" x)"
expect "path outside project blocked" 2 guard-scope-and-leash.sh "$(write s1 /etc/hosts x)"
expect "parent traversal blocked" 2 guard-scope-and-leash.sh "$(write s1 skills/../../x.md x)"
expect "250-line task file passes" 0 guard-scope-and-leash.sh "$(write s1 "$T/docs/tasks/demo/task-01.md" "$(nlines 250)")"
expect "251-line task file blocked" 2 guard-scope-and-leash.sh "$(write s1 "$T/docs/tasks/demo/task-01.md" "$(nlines 251)")"
nlines 249 >"$T/docs/tasks/demo/task-02.md"
edit() { jq -nc --arg fp "$T/docs/tasks/demo/task-02.md" --arg new "$1" \
  '{session_id:"s1",tool_name:"Edit",tool_input:{file_path:$fp,old_string:"line 5\n",new_string:$new}}'; }
expect "Edit pushing task file to 251 blocked" 2 guard-scope-and-leash.sh "$(edit $'line 5\nx\ny\n')"
expect "Edit landing on 250 passes" 0 guard-scope-and-leash.sh "$(edit $'line 5\nx\n')"
multi="$(jq -nc --arg fp "$T/docs/tasks/demo/task-02.md" '{session_id:"s1",tool_name:"MultiEdit",tool_input:{file_path:$fp,
  edits:[{old_string:"line 1\n",new_string:"line 1\na\n"},{old_string:"line 2\n",new_string:"line 2\nb\n"}]}}')"
expect "MultiEdit pushing task file to 251 blocked" 2 guard-scope-and-leash.sh "$multi"

max="$(jq -r .max_subagents_per_session "$T/.claude/router.json")"
task='{"session_id":"s2","tool_name":"Task","tool_input":{"subagent_type":"general-purpose","description":"x","prompt":"x"}}'
for i in $(seq 1 "$max"); do expect "subagent $i/$max allowed" 0 guard-scope-and-leash.sh "$task"; done
expect "subagent $((max + 1)) blocked by leash" 2 guard-scope-and-leash.sh "$task"
check "leash message names the cap" "grep -q 'leash reached' '$T/err'"
expect "another session has its own leash" 0 guard-scope-and-leash.sh "${task/s2/s3}"

printf '# Task 03\n\n## Target Files\n- `skills/demo/SKILL.md`\n\n## Steps\n1. x\n' >"$T/docs/tasks/demo/task-03.md"
echo "docs/tasks/demo/task-03.md" >"$T/.audit/active-task"
expect "active task: target file passes" 0 guard-scope-and-leash.sh "$(write s1 "$T/skills/demo/SKILL.md" hi)"
expect "active task: non-target blocked" 2 guard-scope-and-leash.sh "$(write s1 "$T/skills/other/SKILL.md" hi)"
expect "active task: docs/ still allowed" 0 guard-scope-and-leash.sh "$(write s1 "$T/docs/notes.md" hi)"
rm "$T/.audit/active-task"
check "blocks are written to the ledger" \
  "jq -se 'map(select(.decision==\"block\" and .hook==\"guard-scope-and-leash\")) | length >= 8' '$L' >/dev/null"

echo "audit-telemetry"
post='{"session_id":"s1","tool_name":"Bash","tool_input":{"command":"curl -H \"Authorization: Bearer abc123\" api_key=SECRET"},"tool_response":{"stdout":"ok"}}'
expect "PostToolUse exits 0" 0 audit-telemetry.sh "$post"
check "appends JSONL with session_id" \
  "tail -n 1 '$L' | jq -e '.event==\"PostToolUse\" and .session_id==\"s1\" and .tool==\"Bash\"' >/dev/null"
check "scrubs secrets from commands" "! tail -n 1 '$L' | grep -Eq 'abc123|SECRET'"
run audit-telemetry.sh '{"session_id":"s1","tool_name":"Task","tool_input":{"model":"opus"}}' >/dev/null
check "maps model to router tier" "tail -n 1 '$L' | jq -e '.tier==\"frontier\"' >/dev/null"
expect "garbage input never blocks" 0 audit-telemetry.sh 'not json'
check "every ledger line is valid JSON" "jq -e . '$L' >/dev/null"

echo "verify-before-complete"
expect "not a git repo: exits 0" 0 verify-before-complete.sh '{"session_id":"s1"}'
empty_out "not a git repo: no block"
(cd "$T" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -q -m init)
expect "no watched changes: exits 0" 0 verify-before-complete.sh '{"session_id":"s1"}'
empty_out "no watched changes: no block"
echo change >"$T/skills/demo/SKILL.md"
touch "$T/FAIL_MARKER"
run verify-before-complete.sh '{"session_id":"s1"}' >/dev/null
expect_json "failing verify blocks Stop" '.decision == "block"' "$T/out"
rm "$T/FAIL_MARKER"
expect "passing verify exits 0" 0 verify-before-complete.sh '{"session_id":"s1","stop_hook_active":true}'
empty_out "passing verify allows Stop"
touch "$T/FAIL_MARKER"
for _ in 1 2 3; do run verify-before-complete.sh '{"session_id":"s4"}' >/dev/null; done
run verify-before-complete.sh '{"session_id":"s4"}' >/dev/null
expect_json "gives up after 3 consecutive blocks" 'has("systemMessage") and (has("decision") | not)' "$T/out"

echo
echo "hook-smoke: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
