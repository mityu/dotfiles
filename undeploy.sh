#!/usr/bin/env bash

rm-link () {
	if [[ -L $1 ]]; then
		rm $1
	fi
}

CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
rm-link ~/.bashrc
rm-link ~/.zshrc
rm-link ~/.vimrc
rm-link ~/.mlterm
rm-link $CONFIG_DIR/alacritty
rm-link $CONFIG_DIR/i3
rm-link $CONFIG_DIR/i3blocks
rm-link $CONFIG_DIR/awesome
rm-link $CONFIG_DIR/wezterm
rm-link $CONFIG_DIR/xkeysnail
rm-link $CONFIG_DIR/xremap
rm-link $CONFIG_DIR/dunst
rm-link $CONFIG_DIR/libinput-gestures.conf
rm-link $CONFIG_DIR/karabiner
rm-link $CONFIG_DIR/rofi
rm-link $CONFIG_DIR/nvim
rm-link $CONFIG_DIR/blesh
rm-link $CONFIG_DIR/efm-langserver
rm-link $CONFIG_DIR/pacman
rm-link $CONFIG_DIR/fish
