#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
branch=$(git symbolic-ref --short HEAD 2>/dev/null)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

parts=()
[ -n "$model" ] && parts+=("$model")
[ -n "$branch" ] && parts+=("$branch")
[ -n "$used_pct" ] && parts+=("ctx: ${used_pct}%")

IFS=' | ' ; echo "${parts[*]}"
