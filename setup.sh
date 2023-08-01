#!/bin/bash

set -x
set -e

source ./config.sh

export VERSION="test$(date +%m%d)"
export ANSIBLE_PASSWD="ansible"

if [ -f "config.local.sh" ]; then
	source config.local.sh
fi

export cache=/tmp/cache
mkdir -p $cache
export wget="wget -nc -qP $cache --show-progress"

# Disable needrestart prompt
export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive

for script in setup.d/*.sh; do
  "$script";
done
