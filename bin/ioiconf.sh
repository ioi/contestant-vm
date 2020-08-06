#!/bin/sh

check_ip()
{
	local IP=$1

	if expr "$IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
		return 0
	else
		return 1
	fi
}


do_config()
{

	CONF=$1

	if ! test -f "$CONF"; then
		echo "Can't read $CONF"
		exit 1
	fi

	WORKDIR=`mktemp -d`

	tar jxf $CONF -C $WORKDIR || ( echo "Failed to unpack $CONF"; rm -rf $WORKDIR; exit 1 )

	IP=$(cat $WORKDIR/vpn/ip.conf)
	MASK=$(cat $WORKDIR/vpn/mask.conf)

	if ! check_ip "$IP" || ! check_ip "$MASK"; then
		echo Bad IP numbers
		rm -r $WORKDIR
		exit 1
	fi

	echo "$IP" > /etc/tinc/vpn/ip.conf
	echo "$MASK" > /etc/tinc/vpn/mask.conf
	rm /etc/tinc/vpn/hosts/* 2> /dev/null
	cp $WORKDIR/vpn/hosts/* /etc/tinc/vpn/hosts/
	cp $WORKDIR/vpn/rsa_key.pub /etc/tinc/vpn/
	cp $WORKDIR/vpn/rsa_key.priv /etc/tinc/vpn/
	cp $WORKDIR/vpn/tinc.conf /etc/tinc/vpn

	rm -r $WORKDIR
	USERID=$(cat /etc/tinc/vpn/tinc.conf | grep Name | cut -d\  -f3)
	chfn -f "$USERID" ioi

	systemctl restart tinc@vpn

	return
}


case "$1" in
	vpnstart)
		systemctl start tinc@vpn
		;;
	vpnrestart)
		systemctl restart tinc@vpn
		;;
	vpnstatus)
		systemctl status tinc@vpn
		;;
	settcp)
		sed -i '/^TCPOnly/ s/= no$/= yes/' /etc/tinc/vpn/tinc.conf
		;;
	setudp)
		sed -i '/^TCPOnly/ s/= yes$/= no/' /etc/tinc/vpn/tinc.conf
		;;
	vpnconfig)
		do_config $2
		;;
	settz)
		tz=$2
		if [ -z "$2" ]; then
			cat - <<EOM
No timezone specified. Run tzselect to learn about the valid timezones
available on this system.
EOM
			exit 1
		fi
		if [ -f "/usr/share/zoneinfo/$2" ]; then
			cat - <<EOM
Your timezone will be set to $2 at your next login.
*** Please take note that all dates and times communicated by the IOI 2020 ***
*** organisers will be in Asia/Singapore timezone (GMT+08), unless it is   ***
*** otherwise specified.                                                   ***
EOM
			echo "$2" > /opt/ioi/store/timezone
		else
			cat - <<EOM
Timezone $2 is not valid. Run tzselect to learn about the valid timezones
available on this system.
EOM
			exit 1
		fi
		;;
	*)
		echo Not allowed
		;;
esac

# vim: ft=sh ts=4 sw=4 noet
