# Dotfiles

Personal configuration files for macOS.

## Setup

```bash
git clone https://github.com/yourusername/dotfiles.git ~/Developer/personal/dotfiles
cd ~/Developer/personal/dotfiles

# Create symlinks
ln -s ~/Developer/personal/dotfiles/zshrc ~/.zshrc
ln -s ~/Developer/personal/dotfiles/nano ~/.nano

# Set up local secrets (not tracked in git)
touch ~/.zshrc.local
chmod 600 ~/.zshrc.local
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
# Syntax highlighting for terminal commands
brew install zsh-syntax-highlighting

# Better command output
brew install bat  # Syntax-highlighted 'cat' replacement
brew install eza  # Modern 'ls' replacement with colors and icons

# Optional: Generic colorizer for various commands
brew install grc
```

The dotfiles already include aliases for `bat` and `eza` if installed.

## License

MIT