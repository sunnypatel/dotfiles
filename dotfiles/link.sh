#!/usr/bin/env bash

# Import config path vars
. ./conf_paths.sh

mkdir -p $LVIM_CONFIG_DEST_DIR
mkdir -p $ALACRITTY_CONFIG_DEST_DIR
mkdir -p $PAYPAL_CONFIG_DEST_DIR

# link all config folders
ln -s $SCRIPT_DIR/config/lvim $LVIM_CONFIG_DEST_DIR
ln -s $SCRIPT_DIR/config/paypal $PAYPAL_CONFIG_DEST_DIR

# Links all dotfiles
ln -s $SCRIPT_DIR/zshrc $ZSHRC_DEST_PATH
ln -s $SCRIPT_DIR/tmux.conf $TMUX_CONF_DEST_PATH 
ln -s $SCRIPT_DIR/tmux.conf.local $TMUX_CONF_LOCAL_DEST_PATH 
ln -s $SCRIPT_DIR/gitconfig $GITHUB_CONFIG_DEST_PATH
ln -s $SCRIPT_DIR/config/alacritty/alacritty.yml $ALACRITTY_DEST_PATH
