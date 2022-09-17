# CLI Commands for Contestants

  1. [`ioisetup`](../bin/ioisetup) to get the tinc VPN configuration from the configuration server. It also turns on the firewall so contestants cannot access the internet except IOI-related systems.

  1. [`ioibackup`](../bin/ioibackup.sh) to perform rsync the home directory to the backup server. This replication only includes non-hidden files up to a maximum size of 100 KB.

     1. `ioibackup -r` to restore the home directory backup from server into `/tmp/restore`.

  1. [`ioisubmit`](../bin/ioisubmit) to make a local submission whenever the CMS is inaccessible.

  1. [`ioiexec`](../bin/ioiexec.sh). Please read more about it in [here](./totp.md).

  1. [`ioiconf`](../bin/ioiconf.sh)

     1. `ioiconf [fwstart|fwstop]` to enable/disable firewall outside contest time.

     1. `ioiconf vpnclear` to remove tinc VPN configuration.

     1. `ioiconf [vpnstart|vpnrestart]` to start/restart tinc service.

     1. `ioiconf vpnstatus` to get tinc service status.

     1. `ioiconf setvpnproto [tcp|auto]` to change VPN protocol mode. By default it will use TCP mode. After changing the protocol, you need to restart tinc by execute `ioiconf vpnrestart` command.

     1. `ioiconf settz <timezone>` to change the VM local timezone. It is allowed but not recommended as the host will use their local timezone for all communications.

     1. `ioiconf setautobackup [on|off]` to enable/disable auto-backup when the contest is running.

     1. `ioiconf setscreenlock [on|off]` to enable/disable the screen lock. By default it is turned on with 30 second delay after 15 minutes of idle time.
