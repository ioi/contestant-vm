#!/bin/sh

case "$1" in
	start)
		systemctl start tinc@vpn
		;;
	stop)
		systemctl stop tinc@vpn
		;;
	restart)
		systemctl restart tinc@vpn
		;;
	status)
		systemctl status tinc@vpn
		;;
	*)
		echo Not allowed
		;;
esac
