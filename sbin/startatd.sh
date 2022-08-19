#!/bin/sh

COUNT=0
TIMEOUT=60

while [ ! -f /run/systemd/timesync/synchronized ]
do
	sleep 1
	(( COUNT += 1 ))

	if [ $COUNT -gt $TIMEOUT ]; then
		break
	fi
done

if [ $COUNT -gt $TIMEOUT ]; then
	logger -p local0.info "STARTATD: Starting after $TIMEOUT sec timeout"
else
	logger -p local0.info "STARTATD: Starting after $COUNT sec"
fi

logger -p local0.info "STARTATD: time now is `date`"

# Check for new contest schedule
logger -p local0.info "STARTATD: check new schedule from pop server"
/opt/ioi/sbin/checkschedule.sh

logger -p local0.info "STARTATD: Starting atd"

systemctl start atd

# vim: ft=sh ts=4 noet
