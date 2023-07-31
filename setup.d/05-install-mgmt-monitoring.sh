#!/bin/sh

set -x
set -e

# Install tools needed for management and monitoring

apt -y install net-tools openssh-server ansible xvfb tinc oathtool imagemagick \
	zabbix-agent
