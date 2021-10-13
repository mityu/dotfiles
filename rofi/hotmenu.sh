#!/bin/bash

if [ $# -eq 0 ]; then
    cat <<EOF
wezterm
chromium
sleep
shutdown
reboot
suspend
lock
logout
restart-xkeysnail
wezterm-float
EOF
    exit 0
fi

case $@ in
    sleep) systemctl suspend ;;
    suspend) systemctl suspend ;;
    shutdown) systemctl poweroff ;;  # TODO: Confirm?
    lock) dm-tool lock ;;
    reboot) systemctl reboot ;;
    logout) i3-msg exit ;;  # TODO: Confirm?
    restart-xkeysnail) systemctl --user restart xkeysnail ;;
    wezterm-float) i3-msg -q exec wezterm ;;  # TODO: How can I make the new terminal float?
    *) i3-msg -q exec $@ ;;
esac
exit 0
