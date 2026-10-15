# Dotfiles

Personal macOS config: zsh, nano, iTerm2, and Claude Code instructions. Loaded *from* your existing files, never replacing them, so machine- or company-managed setup (Homebrew, API env) stays intact.

## Install

```bash
git clone git@github.com:gereader/dotfiles.git ~/Developer/personal/dotfiles
cd ~/Developer/personal/dotfiles
./install.sh work --dry-run   # preview
./install.sh work             # or: personal
```

`install.sh` is additive and safe to re-run:
- `~/.zshrc`: appends one guarded `source .../zsh/core.zsh` line (backs up first)
- `~/.zshrc.local`: created if absent (mode 600) with `DOTFILES_MODULES` for the profile
- `~/.nano` symlink + `include` line in `~/.nanorc`
- `~/.claude/CLAUDE.md`: created with `@` imports of `claude/*.md`, or imports appended if it exists

Existing files that conflict are skipped and reported, never overwritten.

| Profile | Modules | Claude instructions |
|---|---|---|
| `personal` | stonks, wireshark, transcribe | base, python |
| `work` | none | base, python, terraform |

iTerm2: Preferences → Profiles → Other Actions → Import JSON Profiles → `iterm2/palenight-profile.json`.

## Layout

```
zsh/core.zsh          prompt, history, completion, aliases, loads ~/.zshrc.local + modules
zsh/optional/*.zsh    opt-in modules, enabled via DOTFILES_MODULES in ~/.zshrc.local
claude/base.md        portable Claude Code instructions
claude/lang/*.md      language-specific instructions
scripts/              helpers (vtt_merge.py for transcribe)
nano/  iterm2/  transcribe/
```

## Optional modules

Enable per machine in `~/.zshrc.local`:

```bash
DOTFILES_MODULES=(wireshark transcribe)
```

- `stonks <TICKER>`: stock price; needs `FINNHUB_API_KEY`
- `wireshark-open <file>`: open pcap in a new Wireshark instance
- `transcribe <file>`: local Whisper.cpp transcription; see `transcribe/README.md`

## Machine-local config

Secrets, PATH additions (e.g. Rancher Desktop), and work-specific Claude rules stay out of this repo:
- `~/.zshrc.local` for shell
- below the `@` imports in `~/.claude/CLAUDE.md` for Claude

## Dependencies

```bash
brew install nano zsh-syntax-highlighting zsh-autosuggestions
brew install bat eza   # optional; aliased if present
```

## License

MIT
