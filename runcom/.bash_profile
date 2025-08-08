# If not running interactively, don't do anything

[ -z "$PS1" ] && return

# Resolve DOTFILES_DIR robustly
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

if [ -z "$DOTFILES_DIR" ] && [ -d "$HOME/.dotfiles" ]; then
  DOTFILES_DIR="$HOME/.dotfiles"
fi

if [ -z "$DOTFILES_DIR" ] || [ ! -d "$DOTFILES_DIR" ]; then
  echo "Unable to find dotfiles, exiting."
  return
fi

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Source the dotfiles (order matters)

for DOTFILE in "$DOTFILES_DIR"/system/.{function,function_*,n,path,env,exports,alias,fzf,grep,prompt,completion,fix,zoxide}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{env,alias,function}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# Set LSCOLORS

eval "$(dircolors -b "$DOTFILES_DIR"/system/.dir_colors)"

# Wrap up

unset CURRENT_SCRIPT SCRIPT_PATH DOTFILE
export DOTFILES_DIR
