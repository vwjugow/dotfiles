#!/bin/bash
# Claude Code statusLine: shows model/cwd, plus a caveman mode badge when active.

input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "claude"' 2>/dev/null)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""' 2>/dev/null)
dirname=$(basename "$cwd" 2>/dev/null)

status="$model"
[ -n "$dirname" ] && status="$status | $dirname"

flag=~/.claude/.caveman-active
if [ -f "$flag" ]; then
  mode=$(cat "$flag" 2>/dev/null)
  status="$status | 🦴 CAVEMAN [$mode]"
fi

printf '%s\n' "$status"
