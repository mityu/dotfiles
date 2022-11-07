#!/bin/bash -x

# Build Vim for MSYS2 bash environment.  Switch to plain MSYS2 environment if
# current environment is mingw64 or mingw32 on MSYS2 because their compiler
# will build Vim for Windows-native environment, not for MSYS2 bash.
if [[ "$(uname)" == "MINGW"* ]]; then
    if [ ! -f "/msys2_shell.cmd" ]; then
        echo '/msys2_shell.cmd not found. Abort.'
        exit 1
    fi
    /msys2_shell.cmd -msys -defterm -no-start $0 $* || exit 1 && exit 0
fi

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
    (! $FORCEBUILD && make -j4) || (make distclean && make -j4) && make -j4 install
fi
