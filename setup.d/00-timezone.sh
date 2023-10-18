#!/bin/bash

set -x
set -e

timedatectl set-timezone Europe/Budapest
#vmware-toolbox-cmd timesync enable
hwclock -w
