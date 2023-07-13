# IOI Contestant VM

## Install & set up

Create a VM: 2 VCPU, 4 GB RAM, 25 GB disk.

Install Ubuntu 22.04 server. Defaults work fine (but please uncheck the "Set up this disk as an LVM group" option). Create a user account called `ansible`.

When Ubuntu install completes, clone or copy this repo into a local directory. E.g.:

```bash
git clone https://github.com/ioi/contestant-vm
sudo -s
cd contestant-vm
# Create config.local.sh; see config.local.sh.sample
# Create config.sh; see config.sh.sample
./setup.sh
./cleanup.sh
cd ..
rm -rf contestant-vm
```

Turn off the VM when you complete the installation.

## Finalise VM image

Boot into install or rescue CDROM (change the boot order in the VM's BIOS if required). Get to a shell (Ctrl+Alt+F2) and zero-out the empty space in the ext4 FS.

```bash
sudo zerofree -v /dev/sda2
```

Shut down the VM.

In the VM settings:

- Remove all CD-ROM and floppy drives.
- In the Hard Disk device, click Compact.

Go to File, Export to OVF, then enter a filename with .ova extension (i.e. to
use an archive format).


## Export to .ova using VMware OVF Tool

To export to .ova on Mac using VMware Fusion:

```bash
NAME="vm-name"

VM_LOCATION="$HOME/Virtual Machines.localized/$NAME.vmwarevm/$NAME.vmx"
OVA_FILEPPATH="$(pwd)/$NAME.ova"

cd "/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool"
./ovftool --acceptAllEulas "$VM_LOCATION" "$OVA_FILEPATH"
```


## Disable side channel mitigations

Ref: https://kb.vmware.com/s/article/79832.

If you don't have Pro version, you can disable manually:

```bash
old_pwd=$(pwd)
tempdir=$(mktemp -d)

tar --same-owner -xvf $OVA_FILEPATH -C "$tempdir"

cd "$tempdir"

# # insert a line to *.ovf
# <vmw:ExtraConfig ovf:required="false" vmw:key="ulm.disableMitigations" vmw:value="TRUE"/>
# # edit line from *.ovf
# <vmw:Config ovf:required="false" vmw:key="tools.syncTimeWithHost" vmw:value="false"/>

openssl sha256 $NAME.ovf $NAME.vmdk > $NAME.mf

chown 64:64 $NAME*.ovf $NAME*.mf $NAME*.vmdk
tar -cvf "$OVA_FILEPATH" $NAME*.ovf $NAME*.mf $NAME*.vmdk

cd "$old_pwd"
rm -rf "$tempdir"
```

## Docs

For more information, see the [docs](docs/README.md).
