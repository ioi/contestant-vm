#!/bin/sh

# 2020-09-13 19:00 2020-09-14 00:00 3 /opt/ioi/sbin/contest.sh prep 0

SCHEDULE="/opt/ioi/misc/schedule2.txt"

TIMENOW=$(date +"%Y-%m-%d %H:%M")

schedule()
{
	JOBID=$1
	
	if [ $(wc -l $SCHEDULE | cut -d\  -f1) -lt "$JOBID" ]; then
		echo DEBUG: No more jobs
		return 1
	fi
	# Remove existing jobs that were created by this script
	for i in `atq | cut -f1`; do
		if at -c $i | grep -q '# AUTO-CONTEST-SCHEDULE'; then
			atrm $i
		fi
	done

        JOB=$(cat $SCHEDULE | head -$JOBID | tail -1)
	ATTIME=$(echo "$JOB" | awk '{print($2, $1)}')
	NEXTTIME=$(echo "$JOB" | awk '{print($1, $2)}')
	CMD=$(echo "$JOB" | cut -d\  -f6-)
	cat - <<EOM | at "$ATTIME" 2> /dev/null
# AUTO-CONTEST-SCHEDULE
/opt/ioi/sbin/atrun.sh exec $JOBID
EOM
	#echo $date, $time, $cmd

	logger -p local0.info "ATRUN: Scheduling next job $JOBID at $NEXTTIME"
}


case "$1" in
	schedule)
		logger -p local0.info "ATRUN: Restart scheduling"
		schedule 1
		;;
	next)
		;;
	exec)
		JOBID=$2
		JOB=$(cat $SCHEDULE | head -$JOBID | tail -1)
		ENDTIME=$(echo "$JOB" | cut -d\  -f3,4)
		if ! echo "$ENDTIME" | grep -q '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\s[0-9]\{2\}:[0-9]\{2\}'; then
			ENDTIME="9999-12-31 23:59"
		fi
		if [ "$TIMENOW" \> "$ENDTIME" ]; then
			NEWJOBID=$(echo "$JOB" | cut -d\  -f5)
			logger -p local0.info "ATRUN: Job $JOBID is over, jumping to $NEWJOBID"
			schedule $NEWJOBID
		else
			CMD=$(echo "$JOB" | cut -d\  -f6-)
			logger -p local0.info "ATRUN: Run $JOBID, $CMD"
			$CMD
			NEWJOBID=$((JOBID+1))
			schedule $NEWJOBID
		fi
		;;
	*)
esac
# vim: ft=sh ts=8 noet
