#!/bin/bash
# Claude Code statusLine: shows model/cwd.

input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "claude"' 2>/dev/null)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""' 2>/dev/null)
dirname=$(basename "$cwd" 2>/dev/null)

status="$model"
[ -n "$dirname" ] && status="$status | $dirname"
printf '%s\n' "$status"
