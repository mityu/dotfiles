#!/usr/bin/env bash

xbacklight $*

if ! which dunstify &> /dev/null; then
    exit 0
fi
brightness=$(xbacklight -get | awk '{print int($1)}')
dunstify -a 'DisplayBrightness' -t 2000 -u low -i display -h int:value:$brightness \
    -h string:x-dunst-stack-tag:displayBrightness "Brightness:${brightness}%"
