#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

# Safe jq helper
jget() {
  jq -r "$1 // empty" <<<"$input" 2>/dev/null || true
}

# Line 1: model | context | time
model=$(jget '.model.display_name')
[ -n "$model" ] || model="unknown"

used_pct=$(jget '.context_window.used_percentage')

if [[ -n "${used_pct:-}" && "$used_pct" != "null" ]]; then
  context_str=$(awk "BEGIN { printf \"ctx %.0f%%\", $used_pct }")
else
  context_str="no context"
fi

# Determine context color based on threshold (Catppuccin Mocha)
if [[ -n "${used_pct:-}" && "$used_pct" != "null" ]]; then
  ctx_color=$(awk "BEGIN {
    pct = $used_pct
    if (pct >= 75) print \"\033[38;2;243;139;168m\"
    else if (pct >= 45) print \"\033[38;2;250;179;135m\"
    else print \"\033[38;2;166;227;161m\"
  }")
else
  ctx_color=$'\033[38;2;166;227;161m'
fi

printf '\033[95m%s\033[0m \033[90m|\033[0m %s%s\033[0m\n' "$model" "$ctx_color" "$context_str"

# Line 2: rate limit usage (only shown when data is available)
five_pct=$(jget '.rate_limits.five_hour.used_percentage')
five_resets=$(jget '.rate_limits.five_hour.resets_at')
week_pct=$(jget '.rate_limits.seven_day.used_percentage')
week_resets=$(jget '.rate_limits.seven_day.resets_at')

rate_parts=()

format_reset() {
  local epoch="$1"
  if [[ -z "$epoch" || "$epoch" == "null" ]]; then
    echo ""
    return
  fi
  local now
  now=$(date +%s)
  local diff=$(( epoch - now ))
  if (( diff <= 0 )); then
    echo "now"
  elif (( diff < 3600 )); then
    echo "$(( diff / 60 ))m"
  elif (( diff < 86400 )); then
    local h=$(( diff / 3600 ))
    local m=$(( (diff % 3600) / 60 ))
    echo "${h}h${m}m"
  else
    echo "$(( diff / 86400 ))d"
  fi
}

pct_color() {
  local pct="$1"
  awk "BEGIN {
    p = $pct
    if (p >= 75) print \"\033[38;2;243;139;168m\"
    else if (p >= 45) print \"\033[38;2;250;179;135m\"
    else print \"\033[38;2;166;227;161m\"
  }"
}

if [[ -n "${five_pct:-}" && "$five_pct" != "null" ]]; then
  reset_str=$(format_reset "$five_resets")
  color=$(pct_color "$five_pct")
  label=$(awk "BEGIN { printf \"%.0f%%\", $five_pct }")
  part="${color}5h: ${label}\033[0m"
  [[ -n "$reset_str" ]] && part="${part} \033[90m(resets ${reset_str})\033[0m"
  rate_parts+=("$part")
fi

if [[ -n "${week_pct:-}" && "$week_pct" != "null" ]]; then
  reset_str=$(format_reset "$week_resets")
  color=$(pct_color "$week_pct")
  label=$(awk "BEGIN { printf \"%.0f%%\", $week_pct }")
  part="${color}7d: ${label}\033[0m"
  [[ -n "$reset_str" ]] && part="${part} \033[90m(resets ${reset_str})\033[0m"
  rate_parts+=("$part")
fi

if (( ${#rate_parts[@]} > 0 )); then
  sep=" \033[90m|\033[0m "
  line=""
  for i in "${!rate_parts[@]}"; do
    [[ $i -gt 0 ]] && line+="$sep"
    line+="${rate_parts[$i]}"
  done
  printf '%b\n' "$line"
fi

# Line 3: cwd | git branch/status
cwd_full=$(jget '.cwd')
[ -n "$cwd_full" ] || cwd_full="${PWD:-/}"

cwd=$(awk -F'/' '{n=NF; if(n>3) print "../"$(n-1)"/"$n; else if(n>=2) print $(n-1)"/"$n; else print $0}' <<<"$cwd_full")

branch=""
git_state=""

if git -C "$cwd_full" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd_full" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || true)

  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd_full" --no-optional-locks rev-parse --short HEAD 2>/dev/null || echo "detached")
  fi

  if ! git -C "$cwd_full" diff --quiet --no-ext-diff 2>/dev/null || \
     ! git -C "$cwd_full" diff --cached --quiet --no-ext-diff 2>/dev/null; then
    git_state=" *"
  fi
fi

if [ -n "$branch" ]; then
  printf '\033[34m%s\033[0m \033[90m|\033[0m \033[94m%s\033[0m\033[91m%s\033[0m\n' "$cwd" "$branch" "$git_state"
else
  printf '\033[34m%s\033[0m\n' "$cwd"
fi
