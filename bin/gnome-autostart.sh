#!/bin/sh

if [ -f /opt/ioi/run/lockscreen ]; then
	sudo /opt/ioi/bin/lockscreen.sh
else
	/opt/ioi/bin/ioisetup
fi
