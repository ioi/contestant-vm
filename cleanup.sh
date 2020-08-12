#!/bin/sh

set -e

apt clean

rm -rf /var/lib/apt/lists/*

# Do this at runlevel 3 (init 3)

systemctl stop rsyslog
systemctl stop open-vm-tools
systemctl stop systemd-journald

# Clear out login records
truncate -s0 /var/log/wtmp
truncate -s0 /var/log/lastlog

# Clear out temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clean up home directories
rm ~ioi/.bash_history || true
rm ~ansible/.bash_history || true
rm ~root/.bash_history || true

# Empty kernel logs
cat /dev/null > /var/log/kern.log
cat /dev/null > /var/log/dmesg

# Remove various logs
rm /var/log/vmware*log || true
rm /var/log/Xorg*log || true
rm /var/log/unattended-upgrades/* || true
rm /var/log/apt/term.log || true
rm -rf /var/log/journal/* || true
rm -rf /var/log/installer || true

# Clear cloud-init, forces regeneration of SSH host keys among other things next boot up
cloud-init clean --logs

# Recreate swap file
swapoff -a
rm /swap.img
dd if=/dev/zero of=/swap.img bs=1048576 count=3908
mkswap /swap.img

PARTKEY=$(/opt/ioi/sbin/genkey.sh)
echo $PARTKEY

# vim: ts=4
