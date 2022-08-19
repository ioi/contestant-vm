# Available Commands (for contestants)

This is a list of commands those are available for contestants

  1. `ioisetup` to get the VPN credential from pop server. It also turn on the firewall so contestants can not access the internet except internal IOI network.

  1. `ioibackup` to perform rsync the home directory into backup server. This replication only includes non-hidden files up to a maximum size of 100 KB.

  1. `ioibackup -r ` to download the home directory backup from server into `/tmp/restore`.

  1. `ioisubmit` to make a local submission whenever the CMS is inaccessible.

  1. `ioiexec`. Please read about it in [TOTP docs page](./totp.md).

  1. `ioiconf`

    1. `ioiconf [fwstart|fwstop]` to enable/disable firewall outside lockdown mode.

    1. `ioiconf vpnclear` to remove VPN configuration.

    1. `ioiconf [vpnstart|vpnrestart]` to start/restart the tinc service.

    1. `ioiconf vpnstatus` to get status from tinc service.

    1. `ioiconf setvpnproto [tcp|auto]` to change VPN protocol mode. By default it will use TCP mode. After changing the protocol, you need to restart the tinc by execute `ioiconf vpnrestart` command.

    1. `ioiconf settz <timezone>` to change the VM local timezone. It is allowed but not recommended as the host will use their local timezone for all communications.

    1. `ioiconf setautobackup [on|off]` to enable/disable auto-backup when the contest is running.

    1. `ioiconf setscreenlock [on|off]` to enable/disable the screen lock. By default it is turned on with 30 second delay after 15 minutes of idle time.
