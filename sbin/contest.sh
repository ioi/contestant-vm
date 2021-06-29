#!/bin/sh

# This needs to run as root!

contestprep()
{
	CONTESTID=$1
	# Prepare system for contest. This is run BEFORE start of contest.

	# init 3
	pkill -9 -u ioi

	UID=$(id -u ioi)
	EPASSWD=$(grep ioi /etc/shadow | cut -d: -f2)
	FULLNAME=$(grep ^ioi: /etc/passwd | cut -d: -f5 | cut -d, -f1)

	# Forces removal of home directory and mail spool
	userdel -rf ioi > /dev/null 2>&1

	# Remove all other user files in /tmp and /var/tmp
	find /tmp -user $UID -exec rm -rf {} \;
	find /var/tmp -user $UID -exec rm -rf {} \;

	# Recreate submissions directory
	rm -rf /opt/ioi/store/submissions
	mkdir /opt/ioi/store/submissions
	chown $UID.$UID /opt/ioi/store/submissions

	/opt/ioi/sbin/mkioiuser.sh

	# Detect cases where the crypt password is invalid, and if so set default passwd
	if [ ${#EPASSWD} -gt 5 ]; then
		echo "ioi:$EPASSWD" | chpasswd -e
	else
		echo "ioi:ioi" | chpasswd
	fi

	chfn -f "$FULLNAME" ioi

	# Put flag to indicate to lock screen
	touch /opt/ioi/run/lockscreen

	/opt/ioi/sbin/firewall.sh start
	USER=$(/opt/ioi/bin/ioicheckuser -q)
	echo "$USER" > /opt/ioi/run/userid.txt
	echo "$CONTESTID" > /opt/ioi/run/contestid.txt
	echo "$CONTESTID" > /opt/ioi/run/lockdown

	# init 5
}

schedule()
{
	# Remove existing jobs that were created by this script
	for i in `atq | cut -f1`; do
		if at -c $i | grep -q '# AUTO-CONTEST-SCHEDULE'; then
			atrm $i
		fi
	done

	while IFS=" " read date time cmd
	do
		cat - <<EOM | at $time $date 2> /dev/null
# AUTO-CONTEST-SCHEDULE
$cmd
EOM
		#echo $date, $time, $cmd
	done < /opt/ioi/misc/schedule
}

monitor()
{
	DATE=$(date +%Y%m%d%H%M%S)
	DISPLAY=:0.0 sudo -u ioi xhost +local:root > /dev/null
	echo "$DATE monitor run" >> /opt/ioi/store/contest.log

	if [ $(seq 2 | shuf | head -1) -eq 2 ]; then
		USER=$(cat /opt/ioi/run/userid.txt)
		DISPLAY=:0.0 xwd -root -silent | convert xwd:- png:- | bzip2 -c - \
			> /opt/ioi/store/screenshots/$USER-$DATE.png.bz2
	fi

	RESOLUTION=$(DISPLAY=:0.0 xdpyinfo | grep dimensions | awk '{print $2}')
	if [ -f /opt/ioi/run/resolution ]; then
		if [ "$RESOLUTION" != "$(cat /opt/ioi/run/resolution)" ]; then
			logger -p local0.alert "MONITOR: Display resolution changed to $RESOLUTION"
			echo "$RESOLUTION" > /opt/ioi/run/resolution
		fi
	else
		echo "$RESOLUTION" > /opt/ioi/run/resolution
		logger -p local0.info "MONITOR: Display resolution is $RESOLUTION"
	fi

	# Check if auto backups are requested
	if [ -f /opt/ioi/config/autobackup ]; then
		# This script runs every minute, but we want to only do backups every 5 mins
		if [ $(( $(date +%s) / 60 % 5)) -eq 0 ]; then
			# Insert a random delay up to 30 seconds so backups don't all start at the same time
			sleep $(seq 30 | shuf | head -1)
			/opt/ioi/bin/ioibackup.sh > /dev/null &
		fi
	fi
}


case "$1" in
	lock)
		touch /opt/ioi/run/lockscreen
		systemctl start i3lock
		;;
	unlock)
		rm /opt/ioi/run/lockscreen
		systemctl stop i3lock
		;;
	prep)
		contestprep $2
		;;
	start)
		rm /opt/ioi/run/lockscreen
		logkeys --start --keymap /opt/ioi/misc/en_US_ubuntu_1204.map
		systemctl stop i3lock
		echo "* * * * * root /opt/ioi/sbin/contest.sh monitor" > /etc/cron.d/contest
		;;
	stop)
		#touch /opt/ioi/run/lockscreen
		#systemctl start i3lock
		logkeys --kill
		rm /etc/cron.d/contest
		;;
	done)
		systemctl stop i3lock
		/opt/ioi/sbin/firewall.sh stop
		rm /opt/ioi/run/lockscreen
		rm /opt/ioi/run/lockdown
		rm /opt/ioi/run/contestid.txt
		rm /opt/ioi/run/userid.txt
		;;
	schedule)
		schedule
		;;
	monitor)
		monitor
		;;
	*)
		;;
esac

# vim: ft=sh ts=4 noet
