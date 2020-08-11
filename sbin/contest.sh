#!/bin/sh

# This needs to run as root.

contestprep()
{
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

	# Recreate submissions directory
	rm -rf /opt/ioi/store/submissions
	mkdir /opt/ioi/store/submissions
	chown $UID.$UID /opt/ioi/store/submissions

	/opt/ioi/sbin/mkioiuser.sh
	echo "ioi:$EPASSWD" | chpasswd -e
	chfn -f "$FULLNAME" ioi

	# Put flag to indicate to lock screen
	touch /opt/ioi/run/lockscreen

	init 5
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
	DISPLAY=:0.0 sudo -u ioi xhost +local:root
	echo "$DATE monitor run" >> /opt/ioi/store/contest.log
	if [ $(seq 5 | shuf | head -1) -eq 5 ]; then
		USER=$(cat /opt/ioi/run/userid.txt)
		DISPLAY=:0.0 xwd -root -silent | convert xwd:- png:- | bzip2 -c - \
			> /opt/ioi/store/screenshots/$USER-$DATE.png.bz2
	fi
	RESOLUTION=$(DISPLAY=:0.0 xdpyinfo | grep dimensions | awk '{print $2}')
	if [ -f /opt/ioi/run/resolution ]; then
		if [ "$RESOLUTION" != "$(cat /opt/ioi/run/resolution)" ]; then
			logger -p local0.alert "Display resolution changed to $RESOLUTION"
			echo "$RESOLUTION" > /opt/ioi/run/resolution
		fi
	else
		echo "$RESOLUTION" > /opt/ioi/run/resolution
		logger -p local0.info "Display resolution is $RESOLUTION"
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
		contestprep
		;;
	start)
		rm /opt/ioi/run/lockscreen
		systemctl stop i3lock
		USER=$(/opt/ioi/bin/ioicheckuser -q)
		echo "$USER" > /opt/ioi/run/userid.txt
		echo "$2" >> /opt/ioi/run/contestid.txt
		echo "* * * * * root /opt/ioi/sbin/contest.sh monitor" > /etc/cron.d/contest
		;;
	stop)
		rm /opt/ioi/run/contestid.txt
		rm /etc/cron.d/contest
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
