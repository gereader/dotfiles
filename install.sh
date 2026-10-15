#!/usr/bin/env bash
# Additive installer: never replaces existing files, only appends guarded lines.
# Usage: ./install.sh <personal|work> [--dry-run]
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="${1:-}"
DRY_RUN=0
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=1
STAMP="$(date +%Y%m%d-%H%M%S)"

case "$PROFILE" in
  personal)
    MODULES="stonks wireshark transcribe"
    CLAUDE_IMPORTS=(base.md lang/python.md)
    ;;
  work)
    MODULES=""
    CLAUDE_IMPORTS=(base.md lang/python.md lang/terraform.md)
    ;;
  *)
    echo "Usage: $0 <personal|work> [--dry-run]" >&2
    exit 1
    ;;
esac

say() { echo "  $*"; }

run() {
  if (( DRY_RUN )); then say "[dry-run] $*"; else eval "$@"; fi
}

backup() {
  local f="$1"
  [[ -e "$f" && ! -L "$f" ]] && run "cp -p '$f' '$f.bak.$STAMP'" && (( ! DRY_RUN )) && say "backed up $f -> $f.bak.$STAMP"
  return 0
}

append_once() {
  local file="$1" marker="$2" content="$3"
  if [[ -f "$file" ]] && grep -qF "$marker" "$file"; then
    say "ok: $file already has '$marker'"
    return
  fi
  backup "$file"
  if (( DRY_RUN )); then
    say "[dry-run] append to $file:"
    sed 's/^/      /' <<<"$content"
  else
    printf '\n%s\n' "$content" >> "$file"
    say "appended to $file"
  fi
}

create_if_absent() {
  local file="$1" content="$2" mode="${3:-644}"
  if [[ -e "$file" ]]; then
    say "ok: $file exists, leaving it alone"
    return
  fi
  if (( DRY_RUN )); then
    say "[dry-run] create $file (mode $mode):"
    sed 's/^/      /' <<<"$content"
  else
    printf '%s\n' "$content" > "$file"
    chmod "$mode" "$file"
    say "created $file"
  fi
}

link_if_absent() {
  local target="$1" link="$2"
  if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
    say "ok: $link already linked"
  elif [[ -e "$link" || -L "$link" ]]; then
    say "skip: $link exists and is not our symlink; resolve manually"
  else
    run "ln -s '$target' '$link'"
    (( DRY_RUN )) || say "linked $link -> $target"
  fi
}

echo "Installing dotfiles ($PROFILE) from $DOTFILES_DIR"

echo "zsh:"
append_once "$HOME/.zshrc" "$DOTFILES_DIR/zsh/core.zsh" \
"# dotfiles
[ -f \"$DOTFILES_DIR/zsh/core.zsh\" ] && source \"$DOTFILES_DIR/zsh/core.zsh\""
create_if_absent "$HOME/.zshrc.local" \
"# Machine-local config, not tracked in git. Sourced by dotfiles core.zsh.
# Available: $(ls "$DOTFILES_DIR/zsh/optional" | sed 's/\.zsh$//' | tr '\n' ' ')
DOTFILES_MODULES=($MODULES)" 600

echo "nano:"
link_if_absent "$DOTFILES_DIR/nano" "$HOME/.nano"
append_once "$HOME/.nanorc" 'include ~/.nano/*.nanorc' 'include ~/.nano/*.nanorc'

echo "claude:"
run "mkdir -p '$HOME/.claude'"
imports=""
for f in "${CLAUDE_IMPORTS[@]}"; do imports+="@$DOTFILES_DIR/claude/$f"$'\n'; done
if [[ -e "$HOME/.claude/CLAUDE.md" ]]; then
  for f in "${CLAUDE_IMPORTS[@]}"; do
    append_once "$HOME/.claude/CLAUDE.md" "@$DOTFILES_DIR/claude/$f" "@$DOTFILES_DIR/claude/$f"
  done
else
  create_if_absent "$HOME/.claude/CLAUDE.md" \
"${imports}
# Machine-specific instructions below (not tracked in dotfiles)"
fi

echo "Done. Open a new terminal or run: source ~/.zshrc"
