# ioi2020-image

## VM Image Finalisation

Boot into install or rescure CDROM. Get to a shell and zero-out the empty space in the ext4 FS.

$ zerofree -v /dev/sda2

Shutdown the VM.

In the VM settings:

- Remove all CDROM and floppy drives.
- In the Hard Disk device, click Defragment, then click Compact.

Go to File, Export to OVF, then enter a filename with .ova extension.
- 
