#!/bin/bash

if [[ $MSYSTEM != "" ]]; then
    if ! openfiles &> /dev/null; then
        powershell start-process \"$(cygpath -w /msys2_shell.cmd)\" \
            -Verb runas -ArgumentList ^-mingw64,$(readlink -f $0)
        exit 0
    fi
    export MSYS=winsymlinks:nativestrict
fi

SCRIPT_DIR=$(cd $(dirname $0);pwd)
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}

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
ln -snfv ${SCRIPT_DIR}/dot_vim ~/.vim


echo "Deploying .mlterm/"
ln -snfv $SCRIPT_DIR/dot_mlterm ~/.mlterm

echo "Deploying .alacritty"
ln -snfv ${SCRIPT_DIR}/alacritty $CONFIG_DIR/alacritty

echo "Deploying i3/"
ln -snfv ${SCRIPT_DIR}/i3 $CONFIG_DIR/i3

echo "Deploying i3blocks/"
ln -snfv ${SCRIPT_DIR}/i3blocks $CONFIG_DIR/i3blocks

echo "Deploying wezterm/"
ln -snfv ${SCRIPT_DIR}/wezterm $CONFIG_DIR/wezterm

echo "Deploying xkeysnail/"
ln -snfv ${SCRIPT_DIR}/xkeysnail $CONFIG_DIR/xkeysnail

echo "Deploying xremap/"
ln -snfv ${SCRIPT_DIR}/xremap $CONFIG_DIR/xremap

echo "Deploygin dunst/"
ln -snfv $SCRIPT_DIR/dunst $CONFIG_DIR/dunst
