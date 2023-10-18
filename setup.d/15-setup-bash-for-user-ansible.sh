#!/bin/bash

set -x
set -e

# setup bash aliases for ansible user
cp /opt/ioi/misc/bash_aliases ~ansible/.bash_aliases
chmod 644 ~ansible/.bash_aliases
chown ansible.ansible ~ansible/.bash_aliases
