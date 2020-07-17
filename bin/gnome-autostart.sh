#!/bin/sh

source /opt/ioi/misc/config

if [ -f /opt/ioi/run/lockscreen ]; then
	sudo /opt/ioi/bin/lockscreen.sh
else
	if [ "$DOSETUP" = "1" ]; then
		/opt/ioi/bin/ioisetup
	fi
fi
