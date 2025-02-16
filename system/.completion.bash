# Dotfiles

_dotfiles_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W 'clean dock duti edit help macos test update' -- $cur ) );
}

complete -o default -F _dotfiles_completions dot

# npm (https://docs.npmjs.com/cli/completion)

if is-executable npm; then
  . <(npm completion)
fi

# Bash

if [is-executable brew]; then
  . "$BREW_PREFIX/share/bash-completion/bash_completion"
fi

# tmux

if [is-executable brew]; then
  . "$BREW_PREFIX/etc/bash_completion.d/tmux"
fi

# Git

#
if [is-executable git]; then
  if [  ]; then
    . "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash"
  fi
fi

# pnpm

[ -f ~/.config/tabtab/bash/__tabtab.bash ] && . $HOME/.config/tabtab/bash/__tabtab.bash || true
