#!/bin/sh

SERVER=https://pop.ioi2021.sg/config

if [ -f /opt/ioi/misc/schedule2.txt.firstrun ]; then
	/opt/ioi/sbin/atrun.sh schedule
	rm /opt/ioi/misc/schedule2.txt.firstrun
fi

# Check for new contest schedule
SCHEDFILE=$(mktemp)
wget --timeout=3 --tries=3 -O $SCHEDFILE "${SERVER}/schedule2.txt" > /dev/null 2>&1
if [ $? -eq 0 -a -f $SCHEDFILE ]; then
    diff -q /opt/ioi/misc/schedule2.txt $SCHEDFILE > /dev/null
    if [ $? -ne 0 ]; then
        logger -p local0.info "SCHEDULE: Setting up new contest schedule"
        cp $SCHEDFILE /opt/ioi/misc/schedule2.txt
        /opt/ioi/sbin/atrun.sh schedule
    fi
fi
rm $SCHEDFILE

