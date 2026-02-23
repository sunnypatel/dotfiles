###############################################################################
# .zshenv - Environment Variables
###############################################################################
# Loaded for: ALL shells (interactive, non-interactive, login, non-login)
# Purpose: Essential environment variables, sources .zsh_path for PATH
# Keep minimal - this file runs for every zsh invocation including scripts
#
# Load order: .zshenv -> .zprofile -> .zshrc -> .zlogin
###############################################################################

# Skip system-wide compinit in /etc/zsh/zshrc (saves ~500ms on startup)
# Zimfw completion module handles compinit itself with proper caching
skip_global_compinit=1

###############################################################################
# Essential Environment Variables
###############################################################################

# Dotfiles directory location
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/projects/dotfiles}"

# Editor configuration - project uses neovim
export EDITOR="nvim"
export VISUAL="$EDITOR"

# XDG Base Directory Specification
# Source: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Tell Zsh to read configs from XDG-compliant location instead of ~/
# After stowing, .zshenv lives at ~/.zshenv, other configs at ~/.config/zsh/
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# Locale configuration
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Terminal colors
export CLICOLOR=1
export GREP_COLORS='mt=1;32'
export MANPAGER='less -X'

# macOS-specific: increase file descriptor limit
if [[ "$OSTYPE" == darwin* ]]; then
  ulimit -S -n 8192
fi

###############################################################################
# PATH (loaded from separate file for easy editing)
###############################################################################

source "${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/.zsh_path"

###############################################################################
# Exports (non-secret environment variables)
###############################################################################

source "${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/.zsh_exports"
