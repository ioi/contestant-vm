#!/bin/sh

case "$1" in
	start)
		iptables-restore < /opt/ioi/misc/iptables.save
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
