#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0);pwd)
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}

auto_mkdir (){
    if [ ! -d $1 ]; then
        mkdir $1
        echo "Made directory: $1"
    fi
}


auto_mkdir $XDG_CONFIG_HOME

echo "Deploying .zshrc"
ln -sn ${SCRIPT_DIR}/.zshrc ~/.zshrc


echo "Deploying .vim/"
ln -snfv ${SCRIPT_DIR}/dot_vim ~/.vim


echo "Deploying .mlterm/"
auto_mkdir $HOME/.mlterm
for file in ${SCRIPT_DIR}/dot_mlterm/*
do
    ln -snfv $file ${HOME}/.mlterm
done


echo "Deploying .alacritty"
ln -snfv ${SCRIPT_DIR}/alacritty $CONFIG_DIR/alacritty

echo "Deploying i3/"
ln -snfv ${SCRIPT_DIR}/i3 $CONFIG_DIR/i3

echo "Deploying i3blocks/"
ln -snfv ${SCRIPT_DIR}/i3blocks $CONFIG_DIR/i3blocks

echo "Deploying wezterm/"
ln -snfv ${SCRIPT_DIR}/wezterm $CONFIG_DIR/wezterm
