#!/bin/sh

# Prepare system for contest. This is run BEFORE start of contest.

init 3
pkill -u ioi

UID=$(id -u ioi)
EPASSWD=$(grep ioi /etc/shadow | cut -d: -f2)
FULLNAME=$(grep ioi /etc/passwd | cut -d: -f5 | cut -d, -f1)

# Forces removal of home directory and mail spool
userdel -rf ioi > /dev/null 2>&1

# Remove all other user files in /tmp and /var/tmp
find /tmp -user $UID -exec rm -rf {} \;
find /var/tmp -user $UID -exec rm -rf {} \;

/opt/ioi/sbin/mkioiuser.sh
echo "ioi:$EPASSWD" | chpasswd -e
chfn -f "$FULLNAME" ioi

# Put flag to indicate to lock screen
touch /opt/ioi/run/lockscreen

init 5
