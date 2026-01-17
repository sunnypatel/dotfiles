# Resolve DOTFILES_DIR robustly (always needed for PATH setup)
if [ -z "$DOTFILES_DIR" ]; then
  # Try to resolve from this file (follow symlinks)
  if command -v readlink >/dev/null 2>&1; then
    SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
    RESOLVED=""
    # Prefer GNU readlink -f when available
    RESOLVED=$(readlink -f -- "$SCRIPT_SOURCE" 2>/dev/null) || RESOLVED=""
    if [ -z "$RESOLVED" ]; then
      # Fallback: manually resolve symlinks
      RESOLVED="$SCRIPT_SOURCE"
      while [ -L "$RESOLVED" ]; do
        LINK_TARGET="$(readlink "$RESOLVED")"
        case "$LINK_TARGET" in
          /*) RESOLVED="$LINK_TARGET" ;;
          *) RESOLVED="$(cd "$(dirname "$RESOLVED")" && cd "$(dirname "$LINK_TARGET")" && pwd)/$(basename "$LINK_TARGET")" ;;
        esac
      done
    fi
    DOTFILES_DIR="$(cd "$(dirname "$RESOLVED")/.." && pwd -P)"
  fi
fi

if [ -z "$DOTFILES_DIR" ]; then
  if [ -d "$HOME/projects/dotfiles" ]; then
    DOTFILES_DIR="$HOME/projects/dotfiles"
  elif [ -d "$HOME/.dotfiles" ]; then
    DOTFILES_DIR="$HOME/.dotfiles"
  fi
fi

if [ -z "$DOTFILES_DIR" ] || [ ! -d "$DOTFILES_DIR" ]; then
  echo "Unable to find dotfiles, exiting."
  return
fi

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Source essential dotfiles (PATH, environment, functions - needed for all shells)
for DOTFILE in "$DOTFILES_DIR"/system/.{function,function_*,path,env,exports}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

# Source nvm after PATH is set so nvm can add its paths
[ -f "$DOTFILES_DIR/system/.nvm" ] && . "$DOTFILES_DIR/system/.nvm"

# If not running interactively, skip interactive features
[ -z "$PS1" ] && export DOTFILES_DIR && return

# Source interactive dotfiles (aliases, prompt, completion, etc.)
# Skip bash-specific prompt in zsh (zsh uses Zim's prompt)
if [ -z "$ZSH_VERSION" ]; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{alias,fzf,grep,prompt,completion,fix,zoxide}; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
else
  # In zsh, skip the bash prompt but load other interactive files
  for DOTFILE in "$DOTFILES_DIR"/system/.{alias,fzf,grep,completion,fix,zoxide}; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{env,alias,function}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
elif is-wsl; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{env,alias,function}.wsl; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# Set LSCOLORS (cached for speed)
DIRCOLORS_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/dircolors.sh"
if [ -f "$DIRCOLORS_CACHE" ] && [ "$DIRCOLORS_CACHE" -nt "$DOTFILES_DIR/system/.dir_colors" ]; then
  . "$DIRCOLORS_CACHE"
else
  mkdir -p "$(dirname "$DIRCOLORS_CACHE")"
  dircolors -b "$DOTFILES_DIR/system/.dir_colors" > "$DIRCOLORS_CACHE"
  . "$DIRCOLORS_CACHE"
fi

# Wrap up

unset CURRENT_SCRIPT SCRIPT_PATH DOTFILE
export DOTFILES_DIR
. "$HOME/.cargo/env"
