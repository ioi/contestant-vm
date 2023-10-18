#!/bin/bash

set -x
set -e

# Setup empty SSH authorized keys and passwordless sudo for ansible

mkdir -p ~ansible/.ssh
touch ~ansible/.ssh/authorized_keys
chown -R ansible.ansible ~ansible/.ssh

sed -i '/%sudo/ s/ALL$/NOPASSWD:ALL/' /etc/sudoers
rm /etc/sudoers.d/01-ioi || true
echo "ioi ALL=NOPASSWD: /opt/ioi/bin/ioiconf.sh, /opt/ioi/bin/ioiexec.sh, /opt/ioi/bin/ioibackup.sh" >> /etc/sudoers.d/01-ioi
echo "zabbix ALL=NOPASSWD: /opt/ioi/sbin/genkey.sh" >> /etc/sudoers.d/01-ioi
chmod 440 /etc/sudoers.d/01-ioi

# Deny ioi user from SSH login
# Wrapped in "if" to make script reentrant
if ! grep -s 'DenyUsers ioi' /etc/ssh/sshd_config
then
echo "DenyUsers ioi" >> /etc/ssh/sshd_config
fi
