#!/usr/bin/env bash

function has-cmd() {
	type $1 &> /dev/null
}

function launch() {
	if has-cmd i3-msg; then
		i3-msg -q exec $*
	elif has-cmd awesome-client; then
		awesome-client "require('awful').spawn([[ $* ]])"
	fi
}

if [ $# -eq 0 ]; then
	cat <<EOF
wezterm
firefox
chromium
sleep
shutdown
reboot
suspend
lock
logout
wezterm-float
clipbuffer
firefox-private
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
	wezterm-float) launch ~/.config/i3/open-floating-app.sh wezterm ;;
	clipbuffer) i3-msg -q "exec --no-startup-id gvim -S ~/.config/i3/clipbuffer.vim" ;;
	firefox-private) launch firefox --private-window ;;
	*) launch $@ ;;
esac
exit 0
