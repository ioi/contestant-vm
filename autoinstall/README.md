# Installing Ubuntu through autoinstall/cloud-init with Qemu

Run `start-autoinstall.sh` for setting up the disc. (This will call into setup.sh)

After running setup.sh -- done automatically, call `sudo cleanup.sh` in `/home/ansible/contestant-vm` with ansible user, `rm -rf /home/ansible/contestant-vm` and call into `sudo shutdown now`.

For `zerofree` step, you will have to boot into live-disk (`boot-live-disk.sh`), and initiate `zerofree /dev/sda2` from there.

DO NOT boot the disc afterwards: the boot after `cleanup.sh` is special, and needs to be done from the created image.

## Creating an image

`qemu-img convert -f qcow2 -O vmdk disk.img contestant-vm.vmdk`

Copy the `contestant-vm.vmdk` file to a freshly created (correctly set up) VM from VMWare.
