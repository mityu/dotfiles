#!/bin/bash -x

if [ ! -d "$HOME/.cache" ]; then
    mkdir ~/.cache
fi
if [ ! -d "$HOME/.cache/alacrittybuild" ]; then
    git clone https://github.com/alacritty/alacritty ~/.cache/alacrittybuild
    HASH=null
fi
cd ~/.cache/alacrittybuild
: "${HASH:=$(git rev-parse HEAD)}"
git pull
if [ $HASH == $(git rev-parse HEAD) ]; then
    exit 0
fi
make app
if [ $? -eq 0 ]; then
    if [ -d "/Applications/Alacritty.app" ]; then
        rm -r /Applications/Alacritty.app
    fi
    cp -r ./target/release/osx/Alacritty.app /Applications/Alacritty.app
fi
