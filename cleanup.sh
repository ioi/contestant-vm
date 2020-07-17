#!/bin/sh

set -e

apt clean

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
rm ~ioi/.bash_history
rm ~ansible/.bash_history
rm ~root/.bash_history

# Empty kernel logs
cat /dev/null > /var/log/kern.log
cat /dev/null > /var/log/dmesg

# Remove various logs
rm /var/log/vmware*log
rm /var/log/Xorg*log
rm /var/log/unattended-upgrades/*
rm /var/log/apt/term.log
rm -rf /var/log/journal/*
rm -rf /var/log/installer

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
