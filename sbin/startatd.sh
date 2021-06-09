#!/bin/sh

COUNT=1
while [ ! -f /run/systemd/timesync/synchronized ]
do
	sleep 1
	if [ $COUNT -gt 60 ]; then
		break
	fi
done

if [ $COUNT -gt 30 ]; then
	logger -p local0.info "STARTATD: Starting after 60 sec timeout"
else
	logger -p local0.info "STARTATD: Starting after $COUNT sec"
fi

logger -p local0.info "STARTATD: time now is `date`"

# Check for new contest schedule
/opt/ioi/sbin/checkschedule.sh

logger -p local0.info "STARTATD: Starting atd"

systemctl start atd

# vim: ft=sh ts=4 noet
