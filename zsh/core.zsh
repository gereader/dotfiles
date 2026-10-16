# ============================================================================
# ZSH Configuration
# Sourced from ~/.zshrc (see install.sh); never replaces it.
# ============================================================================

DOTFILES_DIR="${${(%):-%x}:A:h:h}"

# --- Core ZSH Setup ---
# Load version control info (for git branch in prompt) and tab completion
autoload -Uz vcs_info compinit
compinit

# Make tab completion case-insensitive (e.g., 'dev<tab>' matches 'Developer')
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# --- Prompt Configuration ---
# Update prompt and iTerm2 tab title before each command
precmd() {
  vcs_info  # Get current git branch
  
  # Set iTerm2 tab title to show folder name and git branch
  local tab_title="${PWD##*/}"
  if [[ -n ${vcs_info_msg_0_} ]]; then
    tab_title="${tab_title} (${vcs_info_msg_0_})"
  fi
  echo -ne "\033]0;${tab_title}\007"
}

# Configure git branch display format (just branch name + space)
zstyle ':vcs_info:git:*' formats '%b '

# Enable variable substitution in prompt
setopt PROMPT_SUBST

# Set prompt: blue directory, magenta git branch, then $
# Example: ~/Developer/personal main $
PROMPT='%F{blue}%~%f %F{magenta}${vcs_info_msg_0_}%f$ '

# --- History Configuration ---
export HISTSIZE=1000000
export SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Create an alias for searching history
alias hg='history | grep'

# Share history across all terminal sessions
setopt SHARE_HISTORY

# --- Editor ---
export EDITOR=nano
export VISUAL=nano

# --- Navigation Aliases ---
# Quick jumps to common directories
alias dev='cd ~/Developer'
alias devp='cd ~/Developer/personal'
alias devw='cd ~/Developer/work'
alias devo='cd ~/Developer/opensource'

# --- Enhanced Command Aliases ---
# Only create aliases if commands are installed (prevents errors on fresh machines)

# bat: syntax-highlighted cat replacement
if command -v bat &> /dev/null; then
    alias cat='bat'
fi

# eza: modern ls replacement with colors and icons
if command -v eza &> /dev/null; then
    alias ls='eza'
    alias ll='eza -lha'
    alias tree='eza --tree'
fi

# --- Comfort Aliases ---
# Quickly delete all __pycache__ folders in the current directory tree
alias delete-python-cache='find . -type d -name "__pycache__" -exec rm -r {} +'

# --- ZSH Enhancements ---
# Syntax highlighting: colors valid/invalid commands as you type
if [ -f $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Auto-suggestions: suggests commands based on history
if [ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# --- Local Overrides ---
# Machine-specific secrets, PATH entries, and DOTFILES_MODULES (not tracked in git)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# --- Optional Modules ---
# Enable per machine in ~/.zshrc.local, e.g. DOTFILES_MODULES=(wireshark transcribe)
for module in "${DOTFILES_MODULES[@]}"; do
    if [ -f "$DOTFILES_DIR/zsh/optional/${module}.zsh" ]; then
        source "$DOTFILES_DIR/zsh/optional/${module}.zsh"
    else
        echo "dotfiles: unknown module '${module}'" >&2
    fi
done
unset module

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export PATH="$HOME/.local/bin:$PATH"
