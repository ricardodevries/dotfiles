#!/usr/bin/env bash

input=$(cat)

# --- ANSI colors ---
CYAN="\033[36m"
YELLOW="\033[33m"
WHITE="\033[97m"
DIM="\033[2m"
MAGENTA="\033[35m"
RESET="\033[0m"
DIVIDER=" ${MAGENTA}│${RESET} "

# --- helpers ---

# Build a fixed-width progress bar (filled blocks in yellow, empty in dim).
# Usage: make_bar <used_pct_0_to_100> <width>
make_bar() {
  local pct="$1"
  local width="${2:-12}"
  local filled=$(( (pct * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  local empty=$(( width - filled ))
  local bar=""
  local i
  [ "$filled" -gt 0 ] && bar="${YELLOW}"
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  [ "$filled" -gt 0 ] && bar="${bar}${RESET}"
  [ "$empty" -gt 0 ] && bar="${bar}${DIM}"
  for (( i=0; i<empty;  i++ )); do bar="${bar}░"; done
  [ "$empty" -gt 0 ] && bar="${bar}${RESET}"
  printf "%s" "$bar"
}

# Return the visible (printable) length of a string by stripping ANSI escapes.
visible_len() {
  printf "%s" "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -m | tr -d ' '
}

# Pad two strings to fill terminal width: left-aligns $1, right-aligns $3,
# centers $2 relative to the terminal, with spaces filling the gaps.
spread_three() {
  local left="$1"
  local mid="$2"
  local right="$3"
  local term_width="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"

  local llen; llen=$(visible_len "$left")
  local mlen; mlen=$(visible_len "$mid")
  local rlen; rlen=$(visible_len "$right")

  # Center column: mid should be centered in the terminal
  local mid_start=$(( (term_width - mlen) / 2 ))
  local left_pad=$(( mid_start - llen ))
  [ "$left_pad" -lt 2 ] && left_pad=2

  # Right column: flush to terminal right edge
  local right_start=$(( term_width - rlen ))
  local mid_end=$(( mid_start + mlen ))
  local right_pad=$(( right_start - mid_end ))
  [ "$right_pad" -lt 2 ] && right_pad=2

  printf "%b%*s%b%*s%b" \
    "$left"  "$left_pad"  "" \
    "$mid"   "$right_pad" "" \
    "$right"
}


# --- context window ---
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- rate limits ---
five_pct=$(echo    "$input" | jq -r '.rate_limits.five_hour.used_percentage  // empty')
five_reset=$(echo  "$input" | jq -r '.rate_limits.five_hour.resets_at        // empty')
week_pct=$(echo    "$input" | jq -r '.rate_limits.seven_day.used_percentage  // empty')

# --- build three sections ---
sec_left=""
sec_mid=""
sec_right=""

if [ -n "$ctx_used" ]; then
  pct_int=$(printf "%.0f" "$ctx_used")
  sec_left="${CYAN}Ctx:${RESET} ${WHITE}${pct_int}%${RESET}"
fi

if [ -n "$five_pct" ]; then
  pct_int=$(printf "%.0f" "$five_pct")
  bar=$(make_bar "$pct_int" 12)

  # Time remaining until reset (matches what Claude.ai UI shows)
  elapsed_label=""
  if [ -n "$five_reset" ] && [ "$five_reset" != "null" ]; then
    remaining_secs=$(( five_reset - $(date +%s) ))
    [ "$remaining_secs" -lt 0 ] && remaining_secs=0
    r_h=$(( remaining_secs / 3600 ))
    r_m=$(( (remaining_secs % 3600) / 60 ))
    if [ "$r_h" -gt 0 ]; then
      remaining_label="${r_h}H ${r_m}M"
    else
      remaining_label="${r_m}M"
    fi
    elapsed_label=" ${DIM}${remaining_label}${RESET}"
  fi

  sec_mid="${CYAN}5H:${RESET} ${bar} ${WHITE}${pct_int}%${RESET}${elapsed_label}"
fi

if [ -n "$week_pct" ]; then
  pct_int=$(printf "%.0f" "$week_pct")
  bar=$(make_bar "$pct_int" 12)
  sec_right="${CYAN}7D:${RESET} ${bar} ${WHITE}${pct_int}%${RESET}"
fi

# --- render ---
# If all three sections are present, spread them across the terminal width.
# Fall back to simple spacing when fewer sections are available.
if [ -n "$sec_left" ] && [ -n "$sec_mid" ] && [ -n "$sec_right" ]; then
  printf '%b\n' "${sec_left}${DIVIDER}${sec_mid}${DIVIDER}${sec_right}"
elif [ -n "$sec_left" ] && [ -n "$sec_mid" ]; then
  printf '%b\n' "${sec_left}${DIVIDER}${sec_mid}"
elif [ -n "$sec_left" ] && [ -n "$sec_right" ]; then
  printf '%b\n' "${sec_left}${DIVIDER}${sec_right}"
elif [ -n "$sec_left" ]; then
  printf '%b\n' "$sec_left"
elif [ -n "$sec_mid" ]; then
  printf '%b\n' "$sec_mid"
elif [ -n "$sec_right" ]; then
  printf '%b\n' "$sec_right"
fi
