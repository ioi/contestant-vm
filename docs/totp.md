# When VPN/Firewall Goes Wrong

During the contest, if for any reason we need to disable VPN and/or disable the firewall, we can tell the contestants to use the following commands:

* `ioiexec <TOTP> fwstop`
* `ioiexec <TOTP> vpnclear`

Both commands need a TOTP code. To generate one, run the following snippet as root inside any contestant VM.

```bash
function generateTOTP() {
    local PARTKEY=$(/opt/ioi/sbin/genkey.sh)
    local CMDSTRING="$*"

    local FULLKEY=$(echo $PARTKEY $CMDSTRING | sha256sum | cut -d\  -f1)
    oathtool -s 1800 --totp $FULLKEY -d 8 -w 1
}

# how to use
generateTOTP fwstop
generateTOTP vpnclear
```
