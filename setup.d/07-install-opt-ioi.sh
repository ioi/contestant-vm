#!/bin/bash

set -x
set -e

# Copy IOI stuffs into /opt

mkdir -p /opt/ioi
cp -a bin sbin misc /opt/ioi/
cp config.sh /opt/ioi/
mkdir -p /opt/ioi/run
mkdir -p /opt/ioi/store
mkdir -p /opt/ioi/config
mkdir -p /opt/ioi/store/log
mkdir -p /opt/ioi/store/screenshots
mkdir -p /opt/ioi/store/submissions
mkdir -p /opt/ioi/config/ssh

# Add default timezone
echo "Europe/Budapest" > /opt/ioi/config/timezone

# Default to enable screensaver lock
touch /opt/ioi/config/screenlock
