#!/bin/bash

launcher_path=$(dirname $(dirname $(readlink -f $0)))/batfiles/cmdterm.bat

if ! which cmd.exe &> /dev/null; then
    exit 0
elif which cygpath &> /dev/null; then
    launcher_path=$(cygpath -w $launcher_path)
elif which wslpath &> /dev/null; then
    launcher_path=$(wslpath -w $launcher_path)
fi

$(which cmd.exe) /K $launcher_path
