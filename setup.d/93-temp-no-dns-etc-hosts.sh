#!/bin/bash

set -x
set -e

cat <<EOM >>/etc/hosts
172.16.1.1 cmsioi2023.hu
172.16.2.1 backup.cmsioi2023.hu
78.131.88.156 pop.cmsioi2023.hu
EOM

sudo resolvectl flush-caches
