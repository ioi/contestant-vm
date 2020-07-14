#!/bin/sh

CONF=$1


check_ip()
{
	local IP=$1

	if expr "$IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
		return 0
	else
		return 1
	fi
}

if [ "$CONF" = "--clear" ]; then
	rm /etc/tinc/vpn/tinc.conf
	rm /etc/tinc/vpn/ip.conf
	rm /etc/tinc/vpn/mask.conf
	rm /etc/tinc/vpn/hosts/* > /dev/null 2>&1
	exit 0
fi

if ! test -f $CONF; then
	echo "Can't read $CONF"
	exit 1
fi

WORKDIR=`mktemp -d`

tar jxf $CONF -C $WORKDIR

IP=$(cat $WORKDIR/vpn/ip.conf)
MASK=$(cat $WORKDIR/vpn/mask.conf)

if ! check_ip "$IP" || ! check_ip "$MASK"; then
	echo Bad IP numbers
	rm -r $WORKDIR
	exit 1
fi

echo "$IP" > /etc/tinc/vpn/ip.conf
echo "$MASK" > /etc/tinc/vpn/mask.conf
rm /etc/tinc/vpn/hosts/* > /dev/null 2>&1
cp $WORKDIR/vpn/hosts/* /etc/tinc/vpn/hosts/
cp $WORKDIR/vpn/rsa_key.pub /etc/tinc/vpn/
cp $WORKDIR/vpn/rsa_key.priv /etc/tinc/vpn/
cp $WORKDIR/vpn/tinc.conf /etc/tinc/vpn

rm -r $WORKDIR

systemctl restart tinc@vpn

exit 0

# vim: ft=sh ts=4 sw=4 noet
