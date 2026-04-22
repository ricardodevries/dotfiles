#!/usr/bin/env bash
# Dispatch PreToolUse background by tool name.
tool=$(jq -r '.tool_name // ""' 2>/dev/null)
case "$tool" in
  Bash) ~/.claude/hook-bg.sh "#2a0a3d" ;;        # dark purple
  *)    ~/.claude/hook-bg.sh "#003d3d" ;;        # dark teal
esac
exit 0
