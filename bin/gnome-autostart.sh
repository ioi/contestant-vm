#!/bin/bash

source /opt/ioi/misc/config

if [ -f /opt/ioi/run/lockscreen ]; then
	sudo /opt/ioi/bin/lockscreen.sh
else
	if [ "$DOSETUP" = "1" ]; then
		if ! /opt/ioi/bin/ioicheckuser -q; then
			/opt/ioi/bin/ioisetup
		fi
	fi
fi
