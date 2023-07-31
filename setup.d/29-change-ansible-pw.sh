#!/bin/sh

set -x
set -e

echo "ansible:$ANSIBLE_PASSWD" | chpasswd
