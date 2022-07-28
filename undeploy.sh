#!/bin/bash

CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
rm ~/.bashrc
rm ~/.zshrc
rm ~/.vim
# TODO: Remove .mlterm
rm $CONFIG_DIR/alacritty
rm $CONFIG_DIR/i3
rm $CONFIG_DIR/wezterm
rm $CONFIG_DIR/xkeysnail
rm $CONFIG_DIR/xremap
rm $CONFIG_DIR/dunst
