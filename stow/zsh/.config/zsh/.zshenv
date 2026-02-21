# Skip system-wide compinit in /etc/zsh/zshrc
# Zimfw completion module handles compinit itself with proper caching
# Note: This file is needed in ZDOTDIR for subshells where ZDOTDIR is
# already exported and zsh skips ~/.zshenv in favor of $ZDOTDIR/.zshenv
skip_global_compinit=1
