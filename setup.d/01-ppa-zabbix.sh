#!/bin/sh

set -x
set -e

# Install zabbix repo
$wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-2+ubuntu22.04_all.deb
dpkg -i $cache/zabbix-release_5.0-2+ubuntu22.04_all.deb

# Use a different config for Zabbix
sed -i '/^Environment=/ s/zabbix_agentd.conf/zabbix_agentd_ioi.conf/' /lib/systemd/system/zabbix-agent.service
