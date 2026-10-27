#!/usr/bin/env bash
# UserPromptSubmit: after 25 prompts in one session, nudge Codex to suggest /new
# once the current task is done, then every 10 prompts after that. Prints nothing otherwise.
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
dir="$root/.codex/hooks/.counts"
input=$(cat)

# No jq on Windows Git Bash, so pull the field out with sed.
session=$(printf '%s' "$input" | tr -d '\n' | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | tr -cd 'A-Za-z0-9_-')
[ -n "$session" ] || exit 0

mkdir -p "$dir" || exit 0
read -r count 2>/dev/null < "$dir/$session"
count=$(( ${count:-0} + 1 ))
case "$count" in *[!0-9]*) count=1 ;; esac
echo "$count" > "$dir/$session"

if [ "$count" -ge 25 ] && [ $(( (count - 25) % 10 )) -eq 0 ]; then
  echo "Note for Codex: this session is getting long ($count prompts). Once the current task is finished, suggest that the user saves anything unsaved and runs /new."
fi
exit 0
