# Time-based OTP

There are 2 commands that could be used in a lockdown mode.

  * `ioiexec <TOTP> fwstop`
  * `ioiexec <TOTP> vpnclear`

As we can see, both of them need TOTP in order to work. The TOTP itself using `sbin/genkey.sh` command as the first half (to ensure the VM integrity) and the command itself as the second half.

In short we can generate 2 TOTPs using the following function (please run it as root user since it requires root access to read some files).

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
