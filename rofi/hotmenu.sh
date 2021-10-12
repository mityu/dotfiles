#!/bin/bash

if [ $# -eq 0 ]; then
    cat <<EOF
sleep
shutdown
reboot
suspend
lock
EOF
    exit 0
fi

case $@ in
    sleep) systemctl suspend && dm-tool lock ;;
    suspend) systemctl suspend ;;
    shutdown) systemctl poweroff ;;
    lock) dm-tool lock ;;
    reboot) systemctl reboot ;;
esac
exit 0
