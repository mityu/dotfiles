#!/bin/bash

if [ $# -eq 0 ]; then
	cat <<EOF
fullscreen-toggle
floating-toggle
layout-stacking
layout-tabbed
layout-default
layout-toggle-split
i3-commands
EOF
	exit 0
fi

case $@ in
	i3-commands) ;;  # TODO: implement
	*) echo $@ | sed -e 's/-/ /g' | xargs i3-msg -q ;;
esac
exit 0
