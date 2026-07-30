###############################################################################
# .zshrc - Interactive Shell Configuration
###############################################################################
# Loaded for: Interactive shells only
# Purpose: Zimfw init, history, options — sources aliases and functions
#
# Load order: .zshenv -> .zprofile -> .zshrc -> .zlogin
###############################################################################

# Return early if non-interactive shell
[[ -o interactive ]] || return

###############################################################################
# Zimfw Initialization
###############################################################################

ZIM_HOME="${ZDOTDIR:-$HOME}/.zim"

# Download zimfw plugin manager if missing
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and update init.zsh if outdated
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-$HOME}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules
source ${ZIM_HOME}/init.zsh

###############################################################################
# History Configuration
###############################################################################

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# History deduplication and sharing options
setopt EXTENDED_HISTORY          # Record timestamp of command
setopt SHARE_HISTORY             # Share history across all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate when new added
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to history file
setopt HIST_FIND_NO_DUPS         # Don't display duplicates when searching
setopt HIST_IGNORE_SPACE         # Don't save commands starting with space

###############################################################################
# Zsh Options
###############################################################################

setopt AUTO_CD                   # Type directory name to cd
setopt NO_NOMATCH               # Pass through unmatched globs (bash-like)
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shell

###############################################################################
# Directory Colors (Linux only - macOS uses LSCOLORS)
###############################################################################

if [[ "$OSTYPE" != darwin* ]] && [[ -f "${ZDOTDIR:-$HOME}/.dir_colors" ]]; then
  eval "$(dircolors "${ZDOTDIR:-$HOME}/.dir_colors")"
fi

###############################################################################
# Aliases (loaded from separate file for easy editing)
###############################################################################

source "${ZDOTDIR:-$HOME}/.zsh_aliases"

###############################################################################
# Functions (loaded from separate file for easy editing)
###############################################################################

source "${ZDOTDIR:-$HOME}/.zsh_functions"

###############################################################################
# Secrets (API keys, tokens — not committed to git)
###############################################################################

[[ -f "${ZDOTDIR:-$HOME}/.zsh_secrets" ]] && source "${ZDOTDIR:-$HOME}/.zsh_secrets"

# bun completions
[ -s "/home/sunny/.bun/_bun" ] && source "/home/sunny/.bun/_bun"

# PATH shim written by tool installers (uv, rustup); absent on fresh machines
[ -s "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
