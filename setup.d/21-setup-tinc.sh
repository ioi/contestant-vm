#!/bin/bash

set -x
set -e

# Tinc Setup and Configuration

# Setup tinc skeleton config

mkdir -p /etc/tinc/vpn
mkdir -p /etc/tinc/vpn/hosts

cat - <<'EOM' > /etc/tinc/vpn/host-up
#!/bin/bash

source /opt/ioi/config.sh
logger -p local0.info TINC: VPN connection to $NODE $REMOTEADDRESS:$REMOTEPORT is up

# Force time resync as soon as VPN starts
systemctl restart systemd-timesyncd

# Register something on our HTTP server to log connection
INSTANCEID=$(cat /opt/ioi/run/instanceid.txt)
wget -qO- https://$POP_SERVER/ping/$NODE-$NAME-$INSTANCEID &> /dev/null
EOM
chmod 755 /etc/tinc/vpn/host-up
cp /etc/tinc/vpn/host-up /opt/ioi/misc/

cat - <<'EOM' > /etc/tinc/vpn/host-down
#!/bin/bash

logger -p local0.info TINC: VPN connection to $NODE $REMOTEADDRESS:$REMOTEPORT is down
EOM
chmod 755 /etc/tinc/vpn/host-down

# Configure systemd for tinc
systemctl enable tinc@vpn

systemctl disable multipathd
