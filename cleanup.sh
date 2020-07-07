#!/bin/sh

# Do at runlevel 3

systemctl stop rsyslog
systemctl stop open-vm-tools
systemctl stop systemd-journald

cat /dev/null >/var/log/kern.log
cat /dev/null > /var/log/dmesg

rm /var/log/vmware*log
rm /var/log/Xorg*log
rm /var/log/unattended-upgrades/*
rm /var/log/apt/term.log
rm /var/log/dmesg.*
rm -rf /var/log/journal/*
rm -rf /var/log/installer
