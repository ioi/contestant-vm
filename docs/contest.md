# Scheduled Commands for Contests

Around the contest time, various commands will be executed to:

- make sure the contestants start the contest with a fresh home directory, and
- isolate the contestants from the internet.

The commands are executed by via [`sbin/atrun.sh`](../sbin/atrun.sh), which is based on [atd](https://manpages.ubuntu.com/manpages/focal/man8/atd.8.html) scheduler. However, when something happens, admins can also remotely execute the commands manually.

## Schedule file

The schedule is located here: [`misc/schedule2.txt`](../misc/schedule2.txt).

When the VM boots up, it will try to fetch a new schedule hosted on the configuration server (`https://$POP_SERVER$/config/schedule2.txt`). For more details, check `misc/rc.local` -> `sbin/startatd.sh` -> `sbin/checkschedule.sh`.

The schedule file has the following format, with time formatted as `YYYY-mm-dd HH:MM`
```
<start-time> <end-time> <next-if-missed> <shell-command>
```

For example,
```
2020-09-13 19:00 2020-09-14 00:00 3 /opt/ioi/sbin/contest.sh prep 0
```
means that the command will be executed only once between `2020-09-13 19:00` and `2020-09-14 00:00`. If it is missed to execute the job, it may skip the command and directly execute the 3rd command (3rd line).

## Commands

The main contest-related script is here: [`sbin/contest.sh`](../sbin/contest.sh).

1. `contest lock` disables login as `ioi` user before the contest starts ("locks" the contestant). Usually this will be executed remotely to all contestant VMs.
1. `contest prep <cid>` cleans up the VM by recreating the `ioi` user and removes all contestant-related generated data. This also starts the firewall and creates a file indicating that a contest is running (in "lockdown" mode). The `<cid>` itself is an unique contest identifier (unrelated to CMS contest id). Afterwards, the VM will be unlocked.
1. `contest unlock` reenables login as `ioi` user ("unlocks" the contestant). This is already included as part of `prep` above, but admins may manually execute this remotely if for any reason a contestant VM is not unlocked yet.
1. `contest start` starts the keylogger and the cron job for contest monitoring (see below).
1. `contest monitor` is a command that will be executed every minute by a cron job. It will back up the home directory (only if autobackup is enabled) and will capture some data for monitoring purposes:

     * full-screen screenshots (taken every minute but with 50% probability)
     * monitor resolution (checked every minute and will report any changes to `local0` facility)
1. `contest stop` stops the keylogger and the cron job.
1. `contest done` disables the lockdown mode by turning off the firewall and removing the lockdown indicator file.
