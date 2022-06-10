#!/bin/bash -x
if [ ! -d "$HOME/.cache" ]; then
    mkdir ~/.cache
fi
if [ ! -d "$HOME/.cache/vimbuild" ]; then
    git clone https://github.com/vim/vim ~/.cache/vimbuild
    HASH=null
fi
cd ~/.cache/vimbuild
: "${HASH:=$(git rev-parse HEAD)}"
git pull
if [ $HASH == $(git rev-parse HEAD) ]; then
    exit 0
fi
make -j4 && make install
if [ $? -ne 0 ]; then
    make distclean && make -j4 && make install
fi
