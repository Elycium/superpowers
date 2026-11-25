#!/usr/bin/env bash
# Shared helpers for the Hyperarchetype hooks. Sourced by each hook, never run directly.

HYPER_ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
HYPER_ROOT="${HYPER_ROOT//\\//}"
HYPER_ROOT="${HYPER_ROOT%/}"
ROUTER="$HYPER_ROOT/.claude/router.json"

have_jq() { command -v jq >/dev/null 2>&1; }

# router_get <jq-filter>: prints the value, or nothing when it is missing.
router_get() { jq -r "($1) // empty" "$ROUTER" 2>/dev/null; }

# router_list <jq-filter>: prints one array element per line.
router_list() { jq -r "($1) // [] | .[]" "$ROUTER" 2>/dev/null; }

_ledger_rel="$(router_get '.ledger_path' 2>/dev/null)"
LEDGER="$HYPER_ROOT/${_ledger_rel:-.audit/ledger.jsonl}"

now_utc() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# ledger_append <json-object>: adds ts and appends one JSONL line. Never fails the hook.
ledger_append() {
  mkdir -p "$(dirname "$LEDGER")" 2>/dev/null || return 0
  jq -c --arg ts "$(now_utc)" '{ts: $ts} + .' <<<"$1" >>"$LEDGER" 2>/dev/null || true
}

# ledger_count <session_id> <jq-select-expr>: counts matching ledger entries for a session.
ledger_count() {
  [ -f "$LEDGER" ] || { echo 0; return; }
  jq -Rn --arg sid "$1" "[inputs | fromjson? | select(.session_id == \$sid) | select($2)] | length" "$LEDGER" 2>/dev/null || echo 0
}

# rel_path <path>: prints the path relative to the project root. Returns 1 when it is outside.
rel_path() {
  local p="${1//\\//}"
  case "$p" in
    "$HYPER_ROOT"/*) printf '%s\n' "${p#"$HYPER_ROOT"/}" ;;
    /* | [A-Za-z]:/*) printf '%s\n' "$p"; return 1 ;;
    *) p="${p#./}"; printf '%s\n' "$p" ;;
  esac
  case "$p" in ../* | */../* | ..) return 1 ;; esac
  return 0
}

# path_matches <rel> <pattern>: a pattern ending in / matches a directory prefix, otherwise
# it matches the exact path or the path with any suffix (".env" covers ".env.local").
path_matches() {
  local rel="$1" pat="$2"
  case "$pat" in
    */) [[ "$rel" == "$pat"* ]] ;;
    *) [[ "$rel" == "$pat" || "$rel" == "$pat"* ]] ;;
  esac
}
