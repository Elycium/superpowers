#!/usr/bin/env bash
# PreToolUse: enforces scope (allowed/protected paths, active task targets), the task-file
# line cap, and the subagent leash from .claude/router.json. Exit 2 blocks the tool call.
set -u
input="$(cat)"
# shellcheck source=_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

have_jq || exit 0
[ "${HYPER_GUARD:-on}" = "off" ] && exit 0

sid="$(jq -r '.session_id // "unknown"' <<<"$input")"
tool="$(jq -r '.tool_name // ""' <<<"$input")"
fp="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' <<<"$input")"

block() {
  ledger_append "$(jq -nc --arg sid "$sid" --arg tool "$tool" --arg fp "$fp" --arg reason "$1" \
    '{session_id: $sid, event: "PreToolUse", hook: "guard-scope-and-leash", tool: $tool,
      file_path: (if $fp == "" then null else $fp end), decision: "block", reason: $reason}')"
  echo "Hyperarchetype guard blocked ${tool}: $1" >&2
  exit 2
}

# --- Leash: cap subagent fan-out per session ---------------------------------------------
case "$tool" in
  Task | Agent)
    max="$(router_get '.max_subagents_per_session')"; max="${max:-4}"
    used="$(ledger_count "$sid" '.event == "SubagentDispatch"')"
    if [ "$used" -ge "$max" ]; then
      block "subagent leash reached (${used}/${max} this session). Finish with the agents you have, or raise max_subagents_per_session in .claude/router.json."
    fi
    ledger_append "$(jq -c --arg sid "$sid" --arg tool "$tool" --argjson n "$((used + 1))" --argjson max "$max" \
      '{session_id: $sid, event: "SubagentDispatch", hook: "guard-scope-and-leash", tool: $tool,
        subagent_type: (.tool_input.subagent_type // null), model: (.tool_input.model // null),
        description: (.tool_input.description // null), dispatch_number: $n, max: $max}' <<<"$input")"
    exit 0
    ;;
  Write | Edit | MultiEdit | NotebookEdit) ;;
  *) exit 0 ;;
esac

[ -n "$fp" ] || exit 0

# --- Scope: inside the project, not protected, inside allowed_paths ------------------------
if ! rel="$(rel_path "$fp")"; then
  block "${fp} is outside the project root."
fi

while IFS= read -r pat; do
  [ -n "$pat" ] && path_matches "$rel" "$pat" && block "${rel} is protected (scope.protected_paths). A human edits it by hand."
done < <(router_list '.scope.protected_paths')

allowed=0
while IFS= read -r pat; do
  [ -n "$pat" ] && path_matches "$rel" "$pat" && { allowed=1; break; }
done < <(router_list '.scope.allowed_paths')
[ "$allowed" -eq 1 ] || block "${rel} is not in scope.allowed_paths in .claude/router.json."

# --- Active task: only its listed target files (plus docs/ and evals/) --------------------
af="$(router_get '.scope.active_task_file')"; af="${af:-.audit/active-task}"
if [ -f "$HYPER_ROOT/$af" ]; then
  task="$(head -n 1 "$HYPER_ROOT/$af" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [ -n "$task" ] && [ -f "$HYPER_ROOT/$task" ] && [ "$rel" != "$task" ]; then
    ok=0
    while IFS= read -r pat; do
      [ -n "$pat" ] && path_matches "$rel" "$pat" && { ok=1; break; }
    done < <(router_list '.scope.always_allowed_with_active_task')
    if [ "$ok" -eq 0 ]; then
      # Targets are the backticked paths in the "## Target Files" section of the task file.
      targets="$(awk '/^##[[:space:]]+Target Files/{f=1; next} /^##[[:space:]]/{f=0} f' "$HYPER_ROOT/$task" |
        grep -o '`[^`]*`' | tr -d '`')"
      while IFS= read -r t; do
        [ -n "$t" ] && path_matches "$rel" "$t" && { ok=1; break; }
      done <<<"$targets"
    fi
    [ "$ok" -eq 1 ] || block "${rel} is not a target file of the active task ${task}. Add it to that task's '## Target Files' or clear ${af}."
  fi
fi

# --- Task-file cap: docs/tasks/**/*.md must stay at or under the limit --------------------
case "$rel" in
  docs/tasks/*.md)
    cap="$(router_get '.task_file_max_lines')"; cap="${cap:-250}"
    target="$HYPER_ROOT/$rel"
    current=""
    [ -f "$target" ] && current="$(cat "$target")"
    # Simulate the resulting file exactly, then count its lines.
    lines="$(jq -r --arg cur "$current" '
      def nlines: if . == "" then 0 else (split("\n") | length) - (if endswith("\n") then 1 else 0 end) end;
      def apply($e):
        if ($e.replace_all // false) then split($e.old_string) | join($e.new_string)
        else (index($e.old_string)) as $i
          | if $i == null then . else .[0:$i] + $e.new_string + .[($i + ($e.old_string | length)):] end
        end;
      if .tool_name == "Write" then (.tool_input.content // "")
      elif .tool_name == "Edit" then (.tool_input as $e | $cur | apply($e))
      elif .tool_name == "MultiEdit" then reduce (.tool_input.edits // [])[] as $e ($cur; apply($e))
      else $cur end
      | nlines' <<<"$input" 2>/dev/null)" || lines=""
    if [ -n "$lines" ] && [ "$lines" -gt "$cap" ]; then
      block "${rel} would be ${lines} lines; task files must be at most ${cap}. Split it into another task-NN.md."
    fi
    ;;
esac

exit 0
