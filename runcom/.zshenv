###############################################################################
# .zshenv - Environment Variables and PATH Configuration
###############################################################################
# Loaded for: ALL shells (interactive, non-interactive, login, non-login)
# Purpose: PATH, EDITOR, essential environment variables only
# Keep minimal - this file runs for every zsh invocation including scripts
# Source: https://zsh.sourceforge.io/Intro/intro_3.html
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

# Locale configuration
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

###############################################################################
# Platform Detection and Homebrew Configuration
###############################################################################

# Detect platform and set HOMEBREW_PREFIX accordingly
# macOS: /opt/homebrew (Apple Silicon) or /usr/local (Intel)
# Linux: /home/linuxbrew/.linuxbrew
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  elif [[ -d /usr/local/Homebrew ]]; then
    export HOMEBREW_PREFIX="/usr/local"
  fi
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

###############################################################################
# PATH Configuration
###############################################################################

# typeset -U ensures unique entries (no duplicates)
# Replaces the awk-based deduplication from previous setup
typeset -U path

# Build PATH array with priority order (first = highest priority)
path=(
  $DOTFILES_DIR/bin
  $HOME/.cargo/bin
  $HOME/.local/share/pnpm
  $HOME/.bun/bin
  $HOME/.deno/bin
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)

export PATH
