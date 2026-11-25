#!/usr/bin/env bash
# SessionStart (startup|compact): re-injects the Hyperarchetype kernel and logs the bootstrap.
set -u
input="$(cat)"
# shellcheck source=_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

if ! have_jq; then
  echo "Hyperarchetype: jq is not installed, so hooks run in pass-through mode (no guard, no ledger)."
  exit 0
fi

sid="$(jq -r '.session_id // "unknown"' <<<"$input")"
src="$(jq -r '.source // "unknown"' <<<"$input")"

max="$(router_get '.max_subagents_per_session')"; max="${max:-4}"
cap="$(router_get '.task_file_max_lines')"; cap="${cap:-250}"
default_tier="$(router_get '.default_tier')"; default_tier="${default_tier:-mid}"
tiers="$(jq -r '.tiers // {} | to_entries | map("\(.key)=\(.value.model)") | join(", ")' "$ROUTER" 2>/dev/null)"
used="$(ledger_count "$sid" '.event == "SubagentDispatch"')"

active="none"
af="$(router_get '.scope.active_task_file')"; af="${af:-.audit/active-task}"
if [ -f "$HYPER_ROOT/$af" ]; then
  active="$(head -n 1 "$HYPER_ROOT/$af" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [ -n "$active" ] || active="none"
fi

ledger_append "$(jq -nc --arg sid "$sid" --arg src "$src" --arg task "$active" \
  '{session_id: $sid, event: "SessionStart", hook: "session-bootstrap", source: $src, active_task: $task}')"

ctx="Hyperarchetype kernel active (SessionStart: ${src}). Classify every request by the CLAUDE.md tiers before acting: Tier 1 surgical edits skip skills; Tier 2 uses a short plan; Tier 3 runs grill-with-docs first and writes docs/specs + docs/tasks. Router tiers: ${tiers:-unset} (default ${default_tier}). Subagent leash: ${used}/${max} used this session. Task files must stay at or under ${cap} lines. Active task: ${active}. Session misbehaving? Use diagnosing-superpowers with .audit/ledger.jsonl."

jq -nc --arg ctx "$ctx" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
exit 0
