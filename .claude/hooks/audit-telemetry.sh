#!/usr/bin/env bash
# PostToolUse: appends one JSONL event per tool call to .audit/ledger.jsonl for
# diagnosing-superpowers. Never blocks; always exits 0.
set -u
input="$(cat)"
# shellcheck source=_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

have_jq || exit 0

entry="$(jq -c --slurpfile router "$ROUTER" '
  def scrub: gsub("(?<k>bearer\\s+)\\S+"; "\(.k)***"; "i")
    | gsub("(?<k>(api[_-]?key|token|secret|password|passwd|authorization)\\s*[:=]\\s*)\\S+"; "\(.k)***"; "i");
  def clip($n): if type == "string" and length > $n then .[0:$n] + "…" else . end;
  (.tool_input // {}) as $in
  | ($in.model // null) as $model
  | {
      session_id: (.session_id // "unknown"),
      event: "PostToolUse",
      hook: "audit-telemetry",
      tool: (.tool_name // null),
      file_path: ($in.file_path // $in.notebook_path // null),
      command: (($in.command // null) | if . == null then null else (scrub | clip(200)) end),
      pattern: ($in.pattern // null),
      subagent_type: ($in.subagent_type // null),
      model: $model,
      tier: (if $model == null then null
             else ([($router[0].tiers // {}) | to_entries[] | select(.value.model == $model) | .key] | first // null) end),
      input_bytes: ($in | tostring | length),
      response_bytes: ((.tool_response // null) | tostring | length),
      is_error: (((.tool_response // {}) | if type == "object" then (.is_error // .error != null) else false end) // false)
    }' <<<"$input" 2>/dev/null)" || exit 0

[ -n "$entry" ] && ledger_append "$entry"
exit 0
