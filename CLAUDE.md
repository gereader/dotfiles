# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal macOS dotfiles: zsh configuration, nano syntax themes, iTerm2 profile, and utility scripts. Changes here affect the live shell environment via symlinks.

## Setup

```bash
# Symlink into place
ln -s ~/Developer/personal/dotfiles/zshrc ~/.zshrc
ln -s ~/Developer/personal/dotfiles/nano ~/.nano

# Nano config
echo 'include ~/.nano/*.nanorc' >> ~/.nanorc

# Machine-local secrets (not tracked)
touch ~/.zshrc.local && chmod 600 ~/.zshrc.local
```

After editing `zshrc`, reload with `source ~/.zshrc`.

## Key Files

- **`zshrc`** — Main shell config: prompt, aliases, history, optional tool detection (`bat`, `eza`, `grc`), and the `transcribe` function
- **`zsh/functions.zsh`** — `stonks <TICKER>` (Finnhub stock lookup) and `wireshark-open <file>`
- **`scripts/vtt_merge.py`** — Merges WebVTT subtitle cues into readable text blocks; called by `transcribe`
- **`nano/*.nanorc`** — Syntax highlighting files using the Palenight color theme
- **`iterm2/palenight-profile.json`** — iTerm2 color profile (import manually via Preferences)
- **`transcribe/README.md`** — Setup guide for Whisper.cpp local transcription

## Architecture

### Shell Config Loading Order
1. `~/.zshrc` → sources `~/Developer/personal/dotfiles/zshrc`
2. `zshrc` sources `zsh/functions.zsh` (custom functions)
3. `zshrc` sources `~/.zshrc.local` (machine-local secrets/overrides, not in repo)

### Transcription Workflow (`transcribe` function in `zshrc`)
Input file → ffmpeg extracts 16kHz mono WAV → whisper-cli produces `.vtt` → `vtt_merge.py` merges cues → `.transcript.txt` output. Requires `WHISPER_CPP_MODEL_DIR` env var pointing to `ggml-large-v3.bin`.

### Optional Tool Detection
`zshrc` uses `command -v` guards so aliases degrade gracefully if `bat`, `eza`, or `zsh-syntax-highlighting` are not installed.

## Local Secrets Pattern

Machine-specific values (API keys, paths) go in `~/.zshrc.local` — never in this repo. Example entries:
```bash
export FINNHUB_API_KEY="..."
export WHISPER_CPP_MODEL_DIR="$HOME/.local/share/whisper.cpp/models"
```

## Claude Code Config (`claude/`)

- **`claude/statusline.sh`** — Custom status line showing model, context %, rate limits, and git state. Uses Catppuccin Mocha colors. Requires `jq`.

To activate, point `~/.claude/settings.json` at the script:
```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/yourname/Developer/personal/dotfiles/claude/statusline.sh"
  }
}
```

## `vtt_merge.py` Usage

```bash
python3 scripts/vtt_merge.py input.vtt -o output.txt --target 75 --min 25 --gap 1.2
```

Defaults: target block duration 75s, minimum 25s before punctuation break, silence gap 1.2s.
