#!/bin/bash -x
FORCEBUILD=false
if [[ "$1" == "--force" || "$1" == "-f" ]]; then
    FORCEBUILD=true
fi
if [ ! -d "$HOME/.cache" ]; then
    mkdir ~/.cache
fi
if [ ! -d "$HOME/.cache/vimbuild" ]; then
    git clone https://github.com/vim/vim ~/.cache/vimbuild
    FORCEBUILD=true
fi
cd ~/.cache/vimbuild
HASH=$(git rev-parse HEAD)
git pull
if [[ $HASH != $(git rev-parse HEAD) ]] || $FORCEBUILD; then
    (! $FORCEBUILD && make -j4) || (make distclean && make -j4) && make install
fi
