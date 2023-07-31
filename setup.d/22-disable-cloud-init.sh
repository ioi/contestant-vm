#!/bin/sh

set -x
set -e

# Disable cloud-init
touch /etc/cloud/cloud-init.disabled
