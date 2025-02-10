#!/usr/bin/env bash

# Import config path vars
. ./conf_paths.sh

# rm conf files
rm $ZSHRC $TMUX_CONF $TMUX_CONF_LOCAL $GITHUB_CONFIG $ALACRITTY_CONF

# rm conf paths
rm -r $ALACRITTY_CONF_PATH $LVIM_CONF_PATH $PAYPAL_CONF_PATH
