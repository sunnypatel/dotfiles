#!/usr/bin/env bash

# Source the main bash profile (which handles interactive check internally)
. ~/.bash_profile

# pnpm
export PNPM_HOME="/home/sunny/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# Note: cargo/env is already sourced in .bash_profile, no need to source again
