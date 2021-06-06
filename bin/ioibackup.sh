#!/bin/bash


QUIET=0
MODE=backup

while [[ $# -gt 0 ]]; do
	case $1 in
		-r)
			MODE=restore
			shift
			;;
	esac
done

if [ -f /opt/ioi/run/ioibackup.pid ]; then
	if ps -p "$(cat /opt/ioi/run/ioibackup.pid)" > /dev/null; then
		echo Already running
		exit 1
	fi
fi
echo $$ >> /opt/ioi/run/ioibackup.pid

if [ "$MODE" = "backup" ]; then
	cat - <<EOM
Backing up home directory. Only non-hidden files up to a maximum of 1 MB
in size will be backed up.
EOM
	rsync -e "ssh -i /opt/ioi/config/ssh/ioibackup" \
		-avz --delete \
		--max-size=1M --bwlimit=1000 --exclude='.*' --exclude='*.pdf' ~ioi/ ioibackup@ioibackup1.ioi2021.sg:
elif [ "$MODE" = "restore" ]; then
	echo Restoring into /tmp/restore.
	if [ -e /tmp/restore ]; then
		cat - <<EOM
Error: Unable to restore because /tmp/restore already exist. Remove or move
away the existing file or directory before running again.
EOM
	else
		rsync -e "ssh -i /opt/ioi/config/ssh/ioibackup" \
    		    -avz --max-size=1M --bwlimit=1000 --exclude='.*' \
				ioibackup@ioibackup1.ioi2021.sg: /tmp/restore
		chown ioi.ioi /tmp/restore
	fi
fi


rm /opt/ioi/run/ioibackup.pid

# vim: ft=bash ts=4 noet
