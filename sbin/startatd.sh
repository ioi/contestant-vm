#!/bin/sh

COUNT=1
while [ ! -f /run/systemd/timesync/synchronized ]
do
	sleep 1
	if [ $COUNT -gt 30 ]; then
		break
	fi
done

if [ $COUNT -gt 30 ]; then
	logger -p local0.info "STARTATD: Starting after 30 sec timeout"
else
	logger -p local0.info "STARTATD: Starting after $COUNT sec"
fi

logger -p local0.info "STARTATD: time now is `date`"

# Check for new contest schedule
SCHEDFILE=$(mktemp)
wget --timeout=3 --tries=3 -O $SCHEDFILE "${SERVER}/schedule2.txt" > /dev/null 2>&1
if [ $? -eq 0 -a -f $SCHEDFILE ]; then
	diff -q /opt/ioi/misc/schedule2.txt $SCHEDFILE > /dev/null
	if [ $? -ne 0 ]; then
		logger -p local0.info "STARTATD: Setting up new contest schedule"
		cp $SCHEDFILE /opt/ioi/misc/schedule2.txt
		/opt/ioi/sbin/atrun.sh schedule
	fi
fi
rm $SCHEDFILE

logger -p local0.info "STARTATD: Starting atd"

systemctl start atd

# vim: ft=sh ts=4 noet
