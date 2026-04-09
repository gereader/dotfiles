# Dotfiles

Personal configuration files for macOS.

## Setup

```bash
git clone https://github.com/yourusername/dotfiles.git ~/Developer/personal/dotfiles
cd ~/Developer/personal/dotfiles

# Create symlinks
ln -s ~/Developer/personal/dotfiles/zshrc ~/.zshrc
ln -s ~/Developer/personal/dotfiles/nano ~/.nano
ln -s ~/Developer/personal/dotfiles/claude/skills ~/.claude/skills

# Set up local secrets (not tracked in git)
touch ~/.zshrc.local
chmod 600 ~/.zshrc.local

# Tell nano to use nano syntax files
echo 'include ~/.nano/*.nanorc' >> ~/.nanorc

# Add your API keys and secrets:
# echo 'export FINNHUB_API_KEY="your-key-here"' >> ~/.zshrc.local

# Import iTerm2 profile
# iTerm2 → Preferences → Profiles → Other Actions → Import JSON Profiles
# Select ~/Developer/personal/dotfiles/iterm2/palenight-profile.json

# Reload shell
source ~/.zshrc
```

## Includes

- `zshrc` - Zsh config with Palenight prompt, git info, aliases
- `nano/` - Nano syntax highlighting (Python, Bash, YAML, JSON) with Palenight colors
- `zsh/functions.zsh` - Custom shell functions (stonks, wireshark-open)
- `iterm2/` - iTerm2 Palenight color profile
- `claude/` - Claude Code configuration (status line, custom skills)
- `zshrc.local.example` - Template for local machine secrets

**Note:** Create `~/.zshrc.local` on each machine for API keys and other secrets (not committed to git).

```bash
echo 'export FINNHUB_API_KEY="your_api_key_here"' >> ~/.zshrc.local
```

## Features

### Shell Configuration
- Custom prompt with current directory and git branch info
- Case-insensitive tab completion
- Syntax highlighting for commands
- Command history with 10,000 entries

### Aliases
- `dev` - Jump to ~/Developer
- `devp` - Jump to ~/Developer/personal
- `devo` - Jump to ~/Developer/opensource

### Functions
- `stonks <TICKER>` - Get current stock price (requires FINNHUB_API_KEY)
- `wireshark-open <file>` - Open pcap files in new Wireshark instances

## iTerm2 Setup

The included iTerm2 profile features Palenight colors with custom adjustments:
- Foreground text: `#cae697` (lime green for better contrast)
- Background: Dark purple-blue from Palenight theme
- Optimized for readability with syntax highlighting

## Dependencies

Install these via Homebrew for full functionality:

```bash
# Install Nano (Mac uses PICO by default)
brew install nano

# Syntax highlighting for terminal commands
brew install zsh-syntax-highlighting

# Better command output
brew install bat  # Syntax-highlighted 'cat' replacement
brew install eza  # Modern 'ls' replacement with colors and icons

# Required for Claude Code status line
brew install jq

# Optional: Generic colorizer for various commands
brew install grc
```

The dotfiles already include aliases for `bat` and `eza` if installed.

## Claude Code

The `claude/` directory contains configuration for [Claude Code](https://claude.ai/code).

### Skills (Custom Slash Commands)

Custom skills that work across all projects. Each skill is a directory under `claude/skills/` containing a `SKILL.md` file.

**Available skills:**

| Skill | Command | Description |
|-------|---------|-------------|
| **grill-me** | `/grill-me [topic]` | Guided discovery session — asks smart questions to build a complete picture of what you're working on. Leads with assumptions, skips what it can already derive from context. Produces a summary doc in `docs/`. |
| **write-spec** | `/write-spec [project]` | Produces a structured project spec with requirements, architecture, and scope. Generates/updates CLAUDE.md and architecture docs. Runs discovery inline if needed. |
| **spec-to-tasks** | `/spec-to-tasks [spec path]` | Converts a spec into a dependency-aware `TASKS.md` with task IDs, parallel/sequential markers, and a parallel work guide for subagent delegation. |
| **audit-project** | `/audit-project [path]` | Maps an existing codebase — reads everything and produces CLAUDE.md + architecture docs. Run this before `/write-spec` on projects with existing code. |
| **create-skill** | `/create-skill [name]` | Meta-skill for creating new skills. Runs guided discovery to understand what you want, then generates the SKILL.md file. |

**Typical workflow:**
1. `/audit-project` — map an existing project (or skip for greenfield)
2. `/grill-me` — explore the problem space, produce a summary
3. `/write-spec` — formalize into a spec with CLAUDE.md and architecture docs
4. `/spec-to-tasks` — break the spec into actionable tasks with dependency info

Each skill can also be used standalone — they detect existing context and adapt.

**Setup on a new machine:**

```bash
# Create the symlink so Claude Code discovers the skills
ln -s ~/Developer/personal/dotfiles/claude/skills ~/.claude/skills

# Verify skills are available (restart Claude Code, then type / to see them)
ls ~/.claude/skills/
```

That's it — one symlink. Skills are loaded automatically from `~/.claude/skills/` on every Claude Code session.

**Creating new skills:**

Use `/create-skill` inside Claude Code, or manually:
1. Create a directory under `claude/skills/<skill-name>/`
2. Add a `SKILL.md` file with YAML frontmatter and prompt instructions
3. The skill appears as `/<skill-name>` in Claude Code

```yaml
# Minimal SKILL.md example
---
name: my-skill
description: What this skill does
disable-model-invocation: true  # only runs when you type /my-skill
argument-hint: "[optional args]"
---

Instructions for Claude go here. Use $ARGUMENTS to access user input.
```

### Status Line

`claude/statusline.sh` is a custom status line script showing:
- Model name and context window usage (color-coded green/orange/red by threshold)
- Rate limit usage for 5-hour and 7-day windows with reset timers
- Current working directory and git branch/dirty state

**Setup:**

1. Clone this repo (or ensure it's at `~/Developer/personal/dotfiles`)
2. Make the script executable:
   ```bash
   chmod +x ~/Developer/personal/dotfiles/claude/statusline.sh
   ```
3. Add the following to `~/.claude/settings.json` (update the path to match where you cloned this repo):
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "/Users/yourname/Developer/personal/dotfiles/claude/statusline.sh"
     }
   }
   ```
4. Install the `jq` dependency if not already present:
   ```bash
   brew install jq
   ```

Uses [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) colors.

## License

MIT