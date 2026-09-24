#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$branch" ]; then
  dirty=$(git --no-optional-locks -C "$cwd" status --porcelain 2>/dev/null)
  [ -n "$dirty" ] && branch="${branch}*"
fi

parts=()
[ -n "$model" ] && parts+=("$model")
[ -n "$branch" ] && parts+=("$branch")
[ -n "$used_pct" ] && parts+=("$(printf 'ctx: %.0f%%' "$used_pct")")

out=""
for p in "${parts[@]}"; do
  if [ -z "$out" ]; then
    out="$p"
  else
    out="$out | $p"
  fi
done

printf '\033[2m%s\033[0m' "$out"
