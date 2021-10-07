#!/bin/bash

if [ $# -eq 0 ]; then
    cat <<EOF
gvim
wezterm
alacritty
sleep
shutdown
reboot
suspend
firefox
chromium
EOF
    exit 0
fi

case $@ in
    sleep) systemctl suspend ;;
    suspend) systemctl suspend ;;
    shutdown) systemctl shutdown ;;
    reboot) systemctl reboot ;;
    *) exec $@ ;;
esac
