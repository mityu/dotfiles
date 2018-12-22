#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0);pwd)

echo "Deploying .zshrc"
ln -sn ${SCRIPT_DIR}/.zshrc ~/.zshrc


echo "Deploying .vim"
if [ ! -d ${HOME}/.vim ]; then
	mkdir ${HOME}/.vim
	echo "Made directory ${HOME}/.vim"
fi

for file in ${SCRIPT_DIR}/dot_vim/*
do
	ln -snfv $file ${HOME}/.vim
done
