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

systemctl start atd

