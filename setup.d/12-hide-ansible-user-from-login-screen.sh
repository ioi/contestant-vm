#!/bin/bash

set -x
set -e

mkdir -p /var/lib/AccountsService/users
cat - <<EOM > /var/lib/AccountsService/users/ansible
[User]
Language=
XSession=gnome
SystemAccount=true
EOM

chmod 644 /var/lib/AccountsService/users/ansible
