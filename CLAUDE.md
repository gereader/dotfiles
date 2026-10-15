# CLAUDE.md

Personal macOS dotfiles. Installed additively: `install.sh` appends a `source` line to `~/.zshrc` and `@` imports to `~/.claude/CLAUDE.md`; it never replaces existing files. Edits here affect live shells and Claude sessions.

## Layout
- `install.sh <personal|work> [--dry-run]`: idempotent installer; profiles choose modules and Claude imports
- `zsh/core.zsh`: prompt, history, completion, aliases; sets `DOTFILES_DIR`, sources `~/.zshrc.local`, then each module in `DOTFILES_MODULES`
- `zsh/optional/*.zsh`: opt-in functions (stonks, wireshark, transcribe)
- `claude/base.md`, `claude/lang/*.md`: global Claude Code instructions, imported via `@` from `~/.claude/CLAUDE.md`
- `scripts/vtt_merge.py`: used by `transcribe` module
- `claude/statusline.sh`: Mocha status line; not wired by install.sh (per-machine `statusLine` in `~/.claude/settings.json`)
- `iterm2/catppuccin-mocha.itermcolors`: color preset (dark). nano and prompt use named ANSI colors so they inherit it; keep it that way

## Rules
- Nothing machine- or employer-specific in the repo: secrets, PATH entries, company AI rules belong in `~/.zshrc.local` or below the imports in `~/.claude/CLAUDE.md`.
- New optional function → `zsh/optional/<name>.zsh`; reference repo files via `$DOTFILES_DIR`, not hard-coded paths.
- Keep `install.sh` additive and idempotent. Test with `HOME=$(mktemp -d) ./install.sh work`.
- Syntax check: `bash -n install.sh && zsh -n zsh/core.zsh zsh/optional/*.zsh`.
