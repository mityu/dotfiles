#!/bin/bash -x
cd $1
HASH=$(git rev-parse HEAD)
git pull
if [ $HASH == $(git rev-parse HEAD) ]; then
    echo "Alacritty is already up-to-date."
    exit 0
fi
make app
if [ $? -eq 0 ]; then
    echo 'Replace /Applications/Alacritty.app'
    rm -r /Applications/Alacritty.app
    mv ./target/release/osx/Alacritty.app /Applications/Alacritty.app
fi
