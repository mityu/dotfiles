#!/bin/bash

rm-link () {
    if [[ -L $1 ]]; then
        rm $1
    fi
}

CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
rm-link ~/.bashrc
rm-link ~/.zshrc
rm-link ~/.vim
rm-link ~/.mlterm
rm-link $CONFIG_DIR/alacritty
rm-link $CONFIG_DIR/i3
rm-link $CONFIG_DIR/wezterm
rm-link $CONFIG_DIR/xkeysnail
rm-link $CONFIG_DIR/xremap
rm-link $CONFIG_DIR/dunst
rm-link $CONFIG_DIR/libinput-gestures.conf
rm-link $CONFIG_DIR/karabiner
rm-link $CONFIG_DIR/rofi
