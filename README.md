# ioi2020-image

## Install/Setup

Create a VM: 2 VCPU, 4 GB RAM, 25 GB disk.

Install Ubuntu 20.04 server. Defaults work fine. Create a user account called ansible.

When Ubuntu install completes, clone or copy this repo into a local directory. E.g.:

```
git clone https://github.com/lzs/ioi2020-image.git
cd ioi2020-image
./setup.sh
cd ..
rm -rf ioi2020-image
```


## VM Image Finalisation

Boot into install or rescure CDROM. Get to a shell and zero-out the empty space in the ext4 FS.

$ zerofree -v /dev/sda2

Shutdown the VM.

In the VM settings:

- Remove all CDROM and floppy drives.
- In the Hard Disk device, click Defragment, then click Compact.

Go to File, Export to OVF, then enter a filename with .ova extension.
- 
