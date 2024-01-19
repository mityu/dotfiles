#!/bin/bash

if [ ! -d ~/.config/systemd/user ]; then
	mkdir -p ~/.config/systemd/user
fi
cp $(cd $(dirname $0);pwd)/xremap.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user disable xremap.service
systemctl --user enable xremap.service
echo 'Please reboot your computer, or do:'
echo '  $ systemctl --user start xremap.service'
