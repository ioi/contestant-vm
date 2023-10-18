#!/bin/bash

set -x
set -e

# Install zabbix repo
$wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-2+ubuntu22.04_all.deb
dpkg -i $cache/zabbix-release_5.0-2+ubuntu22.04_all.deb
