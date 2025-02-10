#!/usr/bin/env bash

# Import config path vars
. ./conf_paths.sh

mkdir -p $HOME/.config
mkdir -p $HOME/.config/alacritty

# link all config folders
ln -s $SCRIPT_DIR/.config/lvim $LVIM_CONF_PATH
ln -s $SCRIPT_DIR/.config/paypal $PAYPAL_CONF_PATH

# Links all dotfiles
ln -s $SCRIPT_DIR/.zshrc $ZSHRC
ln -s $SCRIPT_DIR/.tmux.conf $TMUX_CONF 
ln -s $SCRIPT_DIR/.tmux.conf.local $TMUX_CONF_LOCAL 
ln -s $SCRIPT_DIR/.gitconfig $GITHUB_CONFIG
ln -s $SCRIPT_DIR/.config/alacritty/alacritty.yml $ALACRITTY_CONF
