#!/bin/bash

source /opt/ioi/config.sh

case "$1" in
	start)
		cat /opt/ioi/misc/iptables.save | \
			sed -e 's/{POP_SERVER}/'${POP_SERVER}'/g' | \
			sed -e 's/{BACKUP_SERVER}/'${BACKUP_SERVER}'/g' | \
			sed -e 's#{SUBNET}#'${SUBNET}'#g' | tee|iptables-restore
		;;
	stop)
		iptables -P INPUT ACCEPT
		iptables -P OUTPUT ACCEPT
		iptables -F
		;;
	*)
		echo Must specify start or stop
		;;
esac

# vim: ft=sh ts=4 noet
