#!/bin/bash

set -x
set -e

# Set flag to run atrun.sh at first boot
touch /opt/ioi/misc/schedule2.txt.firstrun
