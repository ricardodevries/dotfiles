#!/usr/bin/env bash
# Usage: hook-bg.sh <color|default> [sound_name]
color="${1:-default}"
sound="$2"
if [ -n "$TMUX" ]; then
  tmux select-pane -P "bg=$color" 2>/dev/null
fi
if [ -n "$sound" ] && [ -f "/System/Library/Sounds/$sound.aiff" ]; then
  afplay "/System/Library/Sounds/$sound.aiff" >/dev/null 2>&1 &
fi
exit 0
