#!/bin/bash

set -x
set -e

cat >/etc/netplan/01-netcfg.yaml <<EOF
network:
  version: 2
  renderer: NetworkManager
EOF

netplan generate
netplan apply
