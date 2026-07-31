#!/bin/bash
source /etc/profile
/usr/sbin/sshd -D &
vncserver -kill :1 >/dev/null 2>&1
dbus-daemon --session --fork
fcitx5 -d &
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
tail -f /dev/null
