# ============================================================================
# ZSH Configuration
# ============================================================================

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

# --- Navigation Aliases ---
# Quick jumps to common directories
alias dev='cd ~/Developer'
alias devp='cd ~/Developer/personal'
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

# --- Custom Functions ---
# Load custom shell functions (stonks, wireshark-open, etc.)
if [ -f ~/Developer/personal/dotfiles/zsh/functions.zsh ]; then
    source ~/Developer/personal/dotfiles/zsh/functions.zsh
fi


# Transcribe a video/audio file with Whisper.cpp
transcribe() {
    if [ -z "$1" ]; then
        echo "Usage: transcribe <input-file>"
        return 1
    fi

    INPUT="$1"
    BASENAME="${INPUT%.*}"
    WAVFILE="${BASENAME}.wav"
    OUTFILE="${BASENAME}"
    MODEL="$WHISPER_CPP_MODEL_DIR/ggml-large-v3.bin"

    # Extract audio
    ffmpeg -i "$INPUT" -vn -ac 1 -ar 16000 -f wav "$WAVFILE"

    # Run whisper
    whisper-cli -m "$MODEL" -mc 32 -otxt -of "$OUTFILE" "$WAVFILE"

    echo "Done. Transcript saved to: $OUTFILE"
}


# --- Local Secrets ---
# Load machine-specific secrets and API keys (not tracked in git)
# Create ~/.zshrc.local and add: export FINNHUB_API_KEY="your-key"
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/greader/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
