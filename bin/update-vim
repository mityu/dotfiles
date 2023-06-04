#!/bin/bash -e

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

function auto-sudo() {
    if $ISROOT; then
        $*
    else
        echo $PASSWORD | sudo -S -- $*
    fi
}

ISROOT=false
if [[ $(id -u) == 0 || "$(uname)" == "MSYS"* ]]; then
    ISROOT=true
fi

# Password is for "make install", necessary when not a root user.
$ISROOT || read -sp "Password:" PASSWORD

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
    if ! $FORCEBUILD; then
        auto-sudo make -j4 && auto-sudo make -j4 install && exit 0
    fi
    make distclean && auto-sudo make -j4 && auto-sudo make -j4 install
fi
