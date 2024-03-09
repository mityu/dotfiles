#!/bin/bash

if [[ $(uname -o) == Msys ]]; then
	if ! openfiles &> /dev/null; then
		powershell start-process \"$(cygpath -w /msys2_shell.cmd)\" \
			-Verb runas -ArgumentList ^-mingw64,$(readlink -f $0)
		exit 0
	fi
	# export MSYS=winsymlinks:nativestrict
fi

SCRIPT_DIR=$(cd $(dirname $0);pwd)

if [[ $(uname -o) == Msys ]]; then
	$SCRIPT_DIR/deploy.bat
	invoke-cmd () {
		MSYS2_ARG_CONV_EXCL="*" cmd /C $*
	}
	link-file () {
		local src=$(cygpath -w $1)
		local dst=$(cygpath -w $2)
		invoke-cmd mklink $dst $src
	}
	link-dir () {
		local src=$(cygpath -w $1)
		local dst=$(cygpath -w $2)
		invoke-cmd mklink /D $dst $src
	}
	link-file $SCRIPT_DIR/bashrc $HOME/.bashrc
	link-file $SCRIPT_DIR/zshrc $HOME/.zshrc
	link-dir $SCRIPT_DIR/vim $HOME/.vim
	read  # Key wait...
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

echo "Deploying .bashrc"
ln -sn $SCRIPT_DIR/bashrc ~/.bashrc

echo "Deploying .zshrc"
ln -sn ${SCRIPT_DIR}/zshrc ~/.zshrc

echo "Deploying .vim/"
ln -snfv ${SCRIPT_DIR}/vim ~/.vim

echo "Deploying nvim/"
ln -snfv $SCRIPT_DIR/nvim $CONFIG_DIR/nvim

echo "Deploying .alacritty"
ln -snfv ${SCRIPT_DIR}/alacritty $CONFIG_DIR/alacritty

echo "Deploying wezterm/"
ln -snfv ${SCRIPT_DIR}/wezterm $CONFIG_DIR/wezterm

echo "Deploying blesh/"
ln -snfv $SCRIPT_DIR/blesh $CONFIG_DIR/blesh

echo "Deploying efm-langserver/"
ln -snfv $SCRIPT_DIR/efm-langserver $CONFIG_DIR/efm-langserver

if $IS_MAC; then
	echo "Deploying karabiner/"
	ln -snfv $SCRIPT_DIR/karabiner $CONFIG_DIR/karabiner

	echo "Deploying .mlterm/"
	ln -snfv $SCRIPT_DIR/mlterm ~/.mlterm
fi

if $IS_LINUX; then
	echo "Deploying i3/"
	ln -snfv ${SCRIPT_DIR}/i3 $CONFIG_DIR/i3

	echo "Deploying i3blocks/"
	ln -snfv ${SCRIPT_DIR}/i3blocks $CONFIG_DIR/i3blocks

	echo "Deploying xkeysnail/"
	ln -snfv ${SCRIPT_DIR}/xkeysnail $CONFIG_DIR/xkeysnail

	echo "Deploying xremap/"
	ln -snfv ${SCRIPT_DIR}/xremap $CONFIG_DIR/xremap

	echo "Deploygin dunst/"
	ln -snfv $SCRIPT_DIR/dunst $CONFIG_DIR/dunst

	echo "Deploying libinput-gestures.conf"
	ln -snfv $SCRIPT_DIR/libinput-gestures/libinput-gestures.conf \
		$CONFIG_DIR/libinput-gestures.conf

	ln -snfv $SCRIPT_DIR/rofi $CONFIG_DIR/rofi
fi
