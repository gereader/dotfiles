#!/usr/bin/env bash
# Claude Code status line, Catppuccin Mocha (truecolor).
# Line 1: model · effort │ ctx % used/size (colored by tokens) │ cache hit % │ wall (api)
# Line 2: cwd (last two dirs) │ git branch, * if dirty
set -uo pipefail

rgb() { printf '\033[38;2;%s;%s;%sm' "$1" "$2" "$3"; }
RESET=$'\033[0m'
MAUVE=$(rgb 203 166 247)
GREEN=$(rgb 166 227 161)
PEACH=$(rgb 250 179 135)
RED=$(rgb 243 139 168)
TEAL=$(rgb 148 226 213)
OVERLAY=$(rgb 127 132 156)
SURFACE=$(rgb 88 91 112)
BLUE=$(rgb 137 180 250)
LAVENDER=$(rgb 180 190 254)
SEP=" ${SURFACE}│${RESET} "

# Absolute, not %: cost and quality track tokens regardless of window size. 200k = long-context pricing tier.
CTX_WARN_TOKENS=100000
CTX_RED_TOKENS=200000

IFS=$'\x1f' read -r model effort ctx_pct ctx_used ctx_size cache_ratio wall_ms api_ms cwd < <(
  jq -r '[
    (.model.display_name // "unknown"),
    (.effort.level // ""),
    (.context_window.used_percentage // ""),
    (.context_window.total_input_tokens // ""),
    (.context_window.context_window_size // ""),
    (.prompt_cache.hit_ratio // ""),
    (.cost.total_duration_ms // ""),
    (.cost.total_api_duration_ms // ""),
    (.workspace.current_dir // .cwd // "")
  ] | map(tostring) | join("\u001f")'
)

human_tokens() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) { v = n / 1000000; printf (v == int(v) ? "%dM" : "%.1fM"), v }
    else printf "%dk", int(n / 1000 + 0.5)
  }'
}

human_duration() {
  local mins=$(( $1 / 60000 ))
  if (( mins < 1 )); then echo "<1m"
  elif (( mins < 60 )); then echo "${mins}m"
  else echo "$(( mins / 60 ))h$(( mins % 60 ))m"
  fi
}

line1="${MAUVE}${model}"
[[ -n "$effort" ]] && line1+=" · ${effort}"
line1+="${RESET}"

if [[ -n "$ctx_pct" ]]; then
  if (( ${ctx_used:-0} >= CTX_RED_TOKENS )); then ctx_color=$RED
  elif (( ${ctx_used:-0} >= CTX_WARN_TOKENS )); then ctx_color=$PEACH
  else ctx_color=$GREEN
  fi
  ctx="ctx ${ctx_pct}%"
  [[ -n "$ctx_used" && -n "$ctx_size" ]] && ctx+=" $(human_tokens "$ctx_used")/$(human_tokens "$ctx_size")"
  line1+="${SEP}${ctx_color}${ctx}${RESET}"
fi

if [[ -n "$cache_ratio" ]]; then
  line1+="${SEP}${TEAL}cache $(awk -v r="$cache_ratio" 'BEGIN { printf "%d%%", r * 100 + 0.5 }')${RESET}"
else
  line1+="${SEP}${TEAL}cache —${RESET}"
fi

if [[ -n "$wall_ms" ]]; then
  dur=$(human_duration "$wall_ms")
  [[ -n "$api_ms" ]] && dur+=" (api $(human_duration "$api_ms"))"
  line1+="${SEP}${OVERLAY}${dur}${RESET}"
fi

[[ -n "$cwd" ]] || cwd="$PWD"
short_cwd=$(awk -F/ '{ print (NF > 2 ? $(NF-1) "/" $NF : $0) }' <<<"$cwd")
line2="${BLUE}${short_cwd}${RESET}"

if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  dirty=""
  [[ -n $(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | head -1) ]] && dirty="${RED}*${RESET}"
  line2+="${SEP}${LAVENDER}${branch}${RESET}${dirty}"
fi

printf '%s\n%s\n' "$line1" "$line2"
