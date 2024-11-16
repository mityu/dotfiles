#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0);pwd)

if [[ $(uname -o) == Msys ]]; then
	$SCRIPT_DIR/deploy.bat
	invoke-cmd () {
		MSYS2_ARG_CONV_EXCL="*" cmd /C $*
	}
	link-file () {
		local src=$(cygpath -w $1)
		local dst=$(cygpath -w $2)
		invoke-cmd mklink /H $dst $src
	}
	link-dir () {
		local src=$(cygpath -w $1)
		local dst=$(cygpath -w $2)
		invoke-cmd mklink /J $dst $src
	}
	link-file $SCRIPT_DIR/bashrc $HOME/.bashrc
	link-file $SCRIPT_DIR/zshrc $HOME/.zshrc
	link-file $SCRIPT_DIR/vim/bootstrap.vim $HOME/.vimrc
	exit 0
fi

CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}

IS_MAC=false
IS_LINUX=false
if [[ $(uname) == Darwin ]]; then
	IS_MAC=true
else
	IS_LINUX=true
fi

auto_mkdir (){
	if [ ! -d $1 ]; then
		mkdir $1
		echo "Made directory: $1"
	fi
}


auto_mkdir $CONFIG_DIR

ln -sn $SCRIPT_DIR/bashrc ~/.bashrc
ln -sn ${SCRIPT_DIR}/zshrc ~/.zshrc
# ln -snfv ${SCRIPT_DIR}/vim ~/.vim
ln -sn $SCRIPT_DIR/vim/bootstrap.vim ~/.vimrc
ln -snfv $SCRIPT_DIR/nvim $CONFIG_DIR/nvim
ln -snfv ${SCRIPT_DIR}/alacritty $CONFIG_DIR/alacritty
ln -snfv ${SCRIPT_DIR}/wezterm $CONFIG_DIR/wezterm
ln -snfv $SCRIPT_DIR/blesh $CONFIG_DIR/blesh
ln -snfv $SCRIPT_DIR/efm-langserver $CONFIG_DIR/efm-langserver

if $IS_MAC; then
	ln -snfv $SCRIPT_DIR/karabiner $CONFIG_DIR/karabiner
	ln -snfv $SCRIPT_DIR/mlterm ~/.mlterm
fi

if $IS_LINUX; then
	ln -snfv ${SCRIPT_DIR}/i3 $CONFIG_DIR/i3
	ln -snfv ${SCRIPT_DIR}/i3blocks $CONFIG_DIR/i3blocks
	ln -snfv ${SCRIPT_DIR}/xkeysnail $CONFIG_DIR/xkeysnail
	ln -snfv ${SCRIPT_DIR}/xremap $CONFIG_DIR/xremap
	ln -snfv $SCRIPT_DIR/dunst $CONFIG_DIR/dunst
	ln -snfv $SCRIPT_DIR/libinput-gestures/libinput-gestures.conf \
		$CONFIG_DIR/libinput-gestures.conf
	ln -snfv $SCRIPT_DIR/rofi $CONFIG_DIR/rofi

	if type pacman &> /dev/null; then
		ln -snfv $SCRIPT_DIR/pacman $CONFIG_DIR/pacman
	fi
fi
