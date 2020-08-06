#!/bin/sh

PARTKEY=$(/opt/ioi/sbin/genkey.sh)

if [ $# -lt 2 ]; then
	echo "Too few arguments" >&2
	exit 1
fi

TOTP=$1

shift 1

CMDSTRING=$*

FULLKEY=$(echo $PARTKEY $CMDSTRING | sha256sum | cut -d\  -f1)

if ! oathtool -s 600 --totp $FULLKEY -d 8 -w 1 -- "$TOTP" > /dev/null 2>&1; then
	echo "TOTP failed" >&2
	exit;
fi

case $1 in
	fw-disable)
		systemctl stop tinc@vpn
		iptables -P OUTPUT ACCEPT
		iptables -P INPUT ACCEPT
		iptables -F
		;;
esac

# vim: ft=sh ts=4 noet
