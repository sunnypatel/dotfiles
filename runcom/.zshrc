###############################################################################
# .zshrc - Interactive Shell Configuration
###############################################################################
# Loaded for: Interactive shells only
# Purpose: Aliases, functions, completion, prompt, Zimfw modules
# Source: https://zsh.sourceforge.io/Intro/intro_3.html
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
# Aliases
###############################################################################

#
# Shortcuts
#

alias reload="exec zsh"
alias _="sudo"
alias g="git"
alias p="pnpm"
alias npm="pnpm"
alias npx="pnpm dlx"
alias rr="rm -rf"
alias quit="exit"

#
# Directory Listing
#

# Platform-aware ls aliases (macOS uses -G, Linux uses --color=auto)
if [[ "$OSTYPE" == darwin* ]]; then
  alias l="ls -lahA -G"
  alias ll="ls -lA -G"
  alias lt="ls -lhAtr -G"
  alias ld="ls -ld -G */"
else
  alias l="ls -lahA --color=auto"
  alias ll="ls -lA --color=auto"
  alias lt="ls -lhAtr --color=auto"
  alias ld="ls -ld --color=auto */"
fi

#
# Directory Navigation
#

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

#
# Global Aliases (Zsh-only feature)
#

alias -g G="| grep -i"
alias -g H="| head"
alias -g T="| tail"
alias -g L="| less"

#
# Utility Aliases
#

alias aliases="alias | sed 's/=.*//'"
alias paths='echo -e ${PATH//:/\\n}'
alias ip="curl -s ipinfo.io | jq -r '.ip'"
alias hosts="sudo $EDITOR /etc/hosts"
alias week="date +%V"

#
# macOS-Specific Aliases
#

if [[ "$OSTYPE" == darwin* ]]; then
  alias cpwd="pwd | tr -d '\n' | pbcopy"
  alias chrome="open -a /Applications/Google\ Chrome.app"
  alias afk="open /System/Library/CoreServices/ScreenSaverEngine.app"
  alias cleanupds="find . -type f -name '*.DS_Store' -ls -delete"
  alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash/*"
  alias zip="zip -x *.DS_Store -x *__MACOSX* -x *.AppleDouble*"
fi

###############################################################################
# Functions
###############################################################################

# Create directory and cd into it
mk() {
  mkdir -p "$@" && cd "$@"
}

# Calculator
calc() {
  echo "$*" | bc -l
}

###############################################################################
# Grep Configuration
###############################################################################

export GREP_COLORS='mt=1;32'
alias grep="grep --color=auto --exclude-dir={.git,.svn,.hg}"

###############################################################################
# Misc Environment
###############################################################################

export CLICOLOR=1
export MANPAGER='less -X'

# macOS-specific: increase file descriptor limit
if [[ "$OSTYPE" == darwin* ]]; then
  ulimit -S -n 8192
fi
