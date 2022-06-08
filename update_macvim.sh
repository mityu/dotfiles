#!/bin/bash -x
if [ ! -d "$HOME/.cache" ]; then
    mkdir ~/.cache
fi
if [ ! -d "$HOME/.cache/macvimbuild" ]; then
    git clone https://github.com/macvim-dev/macvim ~/.cache/macvimbuild
fi
cd ~/.cache/macvimbuild
HASH=$(git rev-parse HEAD)
git pull
if [ $HASH == $(git rev-parse HEAD) ]; then
    exit 0
fi
make -j4
if [ $? -ne 0 ]; then
    make distclean && make -j4
fi
if [ $? -eq 0 ]; then
    if [ -d "/Applications/MacVim.app" ]; then
        rm -r /Applications/MacVim.app
    fi
    cp -r ./src/MacVim/build/Release/MacVim.app /Applications/MacVim.app
fi
