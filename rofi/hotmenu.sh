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
restart-xremap
wezterm-float
clipbuffer
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
    restart-xremap) systemctl --user restart xremap ;;
    wezterm-float) i3-msg -q exec ~/.config/i3/open-floating-app.sh wezterm ;;
    clipbuffer) i3-msg -q "exec --no-startup-id gvim -S ~/.config/i3/clipbuffer.vim" ;;
    *) i3-msg -q exec $@ ;;
esac
exit 0
