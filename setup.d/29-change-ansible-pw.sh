#!/bin/bash

set -x
set -e

echo "ansible:$ANSIBLE_PASSWD" | chpasswd
