# Contest (lockdown mode)

When the contest is near, some commands will be executed to isolate contestant from the internet. These commands either executed by ATD scheduler (see [atd.md](./atd.md)) or by ansible command.

As mentioned above, isolating the contestant from the internet is the part of the lockdown mode. Whenever the contest starts, the contestant will have a fresh workstation with no leftover data (from previous session) and with no internet connection except instances inside internal IOI network (CMS). In this mode, contestants also can not execute commands from `ioiconf` that could give internet access to them.

Here is the list of available commands

  1. `contest lock` to disable login as IOI user before the contest start. Usually this will be executed remotely using ansible command.

  1. `contest prep <cid>` to cleanup VM by recreating IOI user and remove IOI user's generated data. This command also start the firewall and create a file indicating the lockdown mode. The `<cid>` itself is an unique contest identifier and unrelated to CMS contest id. Later on, the VM will be unlocked after all processes are done.

  1. `contest unlock` to enable login as IOI user. Usually this command is not needed because it is already included inside `contest prep`.

  1. `contest start` to start the keylogger and the cron job for contest monitoring (see below)

  1. `contest monitor` is a command that will be executed every minute by a cron job. It will backup IOI home directory (only if autobackup is enabled) and will capture some data for monitoring purposes. The captured data are:

    * Screenshot (taken every minute but with 50% probability)
    * Monitor resolution (hecked every minute and will report any changes to `local0` facility)

  1. `contest stop` to stop the keylogger and the cron job.

  1. `contest done` to disable the lockdown mode by turn off the firewall and remove a lockdown-indicator file.

  1. `contest schedule` is deprecated (still on investigation), will be removed ASAP.
