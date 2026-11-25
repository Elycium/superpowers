#!/usr/bin/env bash
# Stop: when watched paths changed, run router.json verify.commands before the agent may
# finish. A failure returns {"decision":"block"} so the agent keeps working. After
# verify.max_consecutive_blocks failures in a row it lets the agent stop, to avoid loops.
set -u
input="$(cat)"
# shellcheck source=_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

have_jq || exit 0
sid="$(jq -r '.session_id // "unknown"' <<<"$input")"

log() { # log <decision> <reason> [output]
  ledger_append "$(jq -nc --arg sid "$sid" --arg d "$1" --arg r "$2" --arg out "${3:-}" \
    '{session_id: $sid, event: "Stop", hook: "verify-before-complete", decision: $d, reason: $r,
      output_tail: (if $out == "" then null else $out end)}')"
}

if [ "${HYPER_SKIP_VERIFY:-0}" = "1" ]; then log skip "HYPER_SKIP_VERIFY=1"; exit 0; fi

cd "$HYPER_ROOT" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { log skip "not a git work tree"; exit 0; }

mapfile -t watch < <(router_list '.verify.watch_paths')
[ "${#watch[@]}" -gt 0 ] || watch=(".")
changed="$(git status --porcelain -- "${watch[@]}" 2>/dev/null)"
if [ -z "$changed" ]; then log skip "no changes under verify.watch_paths"; exit 0; fi

# Consecutive blocks since the last pass in this session.
streak=0
if [ -f "$LEDGER" ]; then
  streak="$(jq -Rn --arg sid "$sid" '
    reduce (inputs | fromjson? | select(.session_id == $sid and .hook == "verify-before-complete")) as $e
      (0; if $e.decision == "block" then . + 1 elif $e.decision == "pass" then 0 else . end)' "$LEDGER" 2>/dev/null || echo 0)"
fi
limit="$(router_get '.verify.max_consecutive_blocks')"; limit="${limit:-3}"
if [ "$streak" -ge "$limit" ]; then
  log gave_up "verification failed ${streak} times in a row; allowing stop"
  jq -nc --arg m "Hyperarchetype: verification still failing after ${streak} attempts. Stopping anyway; tell the user what is failing." \
    '{systemMessage: $m}'
  exit 0
fi

to_run() { if command -v timeout >/dev/null 2>&1; then timeout 240 bash -c "$1"; else bash -c "$1"; fi; }

failed=""
output=""
while IFS= read -r cmd; do
  [ -n "$cmd" ] || continue
  if ! out="$(to_run "$cmd" 2>&1)"; then
    failed="$cmd"
    output="$(printf '%s\n' "$out" | tail -n 40)"
    break
  fi
done < <(router_list '.verify.commands')

if [ -n "$failed" ]; then
  log block "verify command failed: ${failed}" "$output"
  jq -nc --arg cmd "$failed" --arg out "$output" \
    '{decision: "block", reason: ("Hyperarchetype verify-before-complete: `" + $cmd + "` failed. Fix it before finishing (or invoke systematic-debugging after 3 attempts).\n\n" + $out)}'
  exit 0
fi

log pass "all verify.commands passed"
exit 0
