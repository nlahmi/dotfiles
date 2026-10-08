#!/bin/bash
# Records which Claude session runs in which WezTerm pane, so Wezurrect
# (in ~/.wezterm.lua) can resume it after a restart.
# Usage: wezterm-pane-session.sh save|clear  (hook payload on stdin)
#
# Gotcha: WezTerm runs on Windows and reads the Windows home, so the file
# must land there. WEZTERM_PANE and USERPROFILE (as a WSL path) only reach
# WSL because the wezterm config adds them to WSLENV.

INPUT=$(cat)
[[ "$WEZTERM_PANE" =~ ^[0-9]+$ ]] || exit 0

[ -d "$USERPROFILE" ] || exit 0
DIR="$USERPROFILE/.claude/pane-sessions"
mkdir -p "$DIR"

case "$1" in
	save) printf '%s' "$INPUT" > "$DIR/$WEZTERM_PANE.json" ;;
	clear) rm -f "$DIR/$WEZTERM_PANE.json" ;;
esac
