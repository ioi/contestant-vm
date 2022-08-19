# Documentation

This is a brief documentation about contestant VM. This VM has a lot of features to support contestants during IOI contest.

There is only one normal local (Ubuntu) user account in the contestant VM for the contestant to use. The username is `ioi` with default password `ioi`.

There are several commands those can be invoked by contestants. Please read about them [on this page](./cli.md).


## Scheduler

The VM has an enhanced scheduler based on provided schedule. Read about it [on ATD page](./atd.md).


## Contest-related

When the contest will be start, there are some preparations to be made. Please refer to [this page](./contest.md) for further information.

Somehow if the VPN does not work as expected, the VM also provided commands to give access to contestants. In order to do that, you need to generate TOTP by [following some steps here](./totp.md). On general case, we don't have to do that as we never block contestants from accessing the public CMS.


## Logging

All IOI-related commands will create logs to `local0` facility. These logs will also be stored in `/opt/ioi/store/log/local.log`. Later we will fetch this data from control server (will be explained on a separate documentation).
