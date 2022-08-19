# ATD (Scheduler)

In order to enforce online contestant to follow the schedule, we integrate [atd](https://manpages.ubuntu.com/manpages/focal/man8/atd.8.html) inside `sbin/atrun.sh` script to run the jobs sequentially.

  1. `atrun` only queues a single job at a time.
  1. `atd` calls `atrun execute <job-id>`.
  1. `atrun` executes the script and queues the next job.

By default, the VM will fetch and evaluate the schedule hosted on pop server (`{POP_SERVER}/config/schedule2.txt`) when the VM boot-up (see `misc/rc.local` -> `sbin/startatd.sh` -> `sbin/checkschedule.sh`). This condition only applies if the schedule is new.


## Schedule file

The schedule itself has the following format with date formatted as `YYYY-mm-dd HH:MM`
```
<start-date> <end-date> <next-if-missed> <shell-command>
```

For example,
```
2020-09-13 19:00 2020-09-14 00:00 3 /opt/ioi/sbin/contest.sh prep 0
```
means that the schedule will be executed only once between `2020-09-13 19:00` and `2020-09-14 00:00`. If it is missed to execute the job, it may skip some jobs and directly execute the 3rd job.
