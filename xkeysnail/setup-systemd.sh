#!/bin/bash
# This script must be executed with `sudo`

groupadd uinput
useradd -G input,uinput $USER
echo 'KERNEL=="event*", NAME="input/%k", MODE="660", GROUP="input"' > /etc/udev/rules.d/input.rules
echo 'KERNEL=="uinput", GROUP="uinput"' > /etc/udev/rules.d/uinput.rules

# Make ~/.config/systemd/user/xkeysnail.service
if [ ! -d ~/.config/systemd/user ]; then
    mkdir -p ~/.config/systemd/user
fi
cat > ~/.config/systemd/user/xkeysnail.service <<EOF
[Unit]
Description=xkeysnail

[Service]
KillMode=process
ExecStart=/usr/local/bin/xkeysnail /home/your_username/.xkeysnail/config.py
ExecStartPre=/usr/bin/xhost +SI:localuser:root
Type=simple
Restart=always

# Update DISPLAY to be the same as `echo $DISPLAY` on your graphical terminal.
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

systemctl --user enable xkeysnail
