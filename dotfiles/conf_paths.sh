#!/usr/bin/env bash

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

# Source paths
ALACRITTY_CONF_PATH=$HOME/configs/alacritty
LVIM_CONF_PATH=$HOME/configs/lvim
PAYPAL_CONF_PATH=$HOME/configs/paypal

# Destination paths
ZSHRC=$HOME/.zshrc
TMUX_CONF=$HOME/.tmux.conf
TMUX_CONF_LOCAL=$HOME/.tmux.conf.local
GITHUB_CONFIG=$HOME/.gitconfig
ALACRITTY_CONF=$ALACRITTY_CONF_PATH/alacritty.yml
