#!/bin/sh

DISPLAY=:0.0 sudo -u ioi xhost +local:root
/usr/bin/i3lock -u -n -t -c 111111 -i /opt/ioi/misc/ioi2021-wallpaper.png
