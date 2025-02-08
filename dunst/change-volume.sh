#!/usr/bin/env bash

pactl $1 @DEFAULT_SINK@ $2

if ! which dunstify &> /dev/null; then
    exit 0
fi

volume=$(LANG=C pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
muted=$(LANG=C pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
icon='audio-volume-high'
message="Volume:${volume}%"
if [[ "$muted" == "yes" ]]; then
    message='Muted'
    volume='0'
fi
if [[ "$volume" == "0" ]]; then
    icon='audio-volume-muted'
fi
dunstify -a 'AudioVolume' -t 2000 -u low -i $icon -h int:value:$volume \
    -h string:x-dunst-stack-tag:audioVolume "$message"
