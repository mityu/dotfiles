#!/bin/bash -eu
if [[ "${1:-}" == "" || "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: `basename $0` <version>|--help|-h"
    echo "Examples:"
    echo " - Download v0.4.0:           $ `basename $0` v0.4.0"
    echo " - Download nightly version:  $ `basename $0` nightly"
    if [[ "${1:-}" == "" ]]; then
        exit 1
    fi
    exit 0
fi
if ! which curl &> /dev/null; then
    echo "'curl' command is required."
    exit 1
fi
# TODO: Support Linux
if which uname &> /dev/null && [[ "`uname`" == "Darwin" ]]; then
    if ! which xattr &> /dev/null ; then
        echo "'xattr' command is required on macOS."
        exit 1
    fi
    curl -O https://github.com/neovim/neovim/releases/download/$1/nvim-macos.tar.gz
    xattr -c ./nvim-macos.tar.gz
    tar xzvf ./nvim-macos.tar.gz
else
    echo "Unsupported OS"
fi
