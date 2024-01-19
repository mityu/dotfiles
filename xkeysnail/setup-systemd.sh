#!/bin/bash
# This script must be executed with `sudo`

groupadd uinput
useradd -G input,uinput $USER
echo 'KERNEL=="event*", NAME="input/%k", MODE="660", GROUP="input"' > /etc/udev/rules.d/70-input.rules
echo 'KERNEL=="uinput", GROUP="uinput"' > /etc/udev/rules.d/70-uinput.rules

# Make ~/.config/systemd/user/xkeysnail.service
if [ ! -d ~/.config/systemd/user ]; then
	mkdir -p ~/.config/systemd/user
fi
cp $(cd $(dirname $0);pwd)/xkeysnail.service ~/.config/systemd/user/
systemctl --user enable xkeysnail
systemctl --user start xkeysnail

# cp $(cd $(dirname $0);pwd)/xkeysnail.service /etc/systemd/system
# systemctl enable xkeysnail
# systemctl start xkeysnail
