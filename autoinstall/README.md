# Installing Ubuntu through autoinstall/cloud-init with Qemu

Run `start-autoinstall.sh` for setting up the disc. (This will call into setup.sh)

After running setup.sh -- done automatically, call `sudo cleanup.sh` in `/home/ansible/contestant-vm` with ansible user, `rm -rf /home/ansible/contestant-vm` and call into `sudo shutdown now`.

For `zerofree` step, you will have to boot into live-disk (`boot-live-disk.sh`), and initiate `zerofree /dev/sda2` from there.

DO NOT boot the disc afterwards: the boot after `cleanup.sh` is special. (the cloud-init script must not be run to create a new SSH identity for each VM)

## Creating a VM image

`qemu-img convert -f qcow2 -O vmdk disk.img contestant-vm.vmdk`

Copy the `contestant-vm.vmdk` file to a freshly created (correctly set up) VM from VMWare.

## Creating a native image with Clonezilla

I've started sshd on my system, so Clonezilla could log in and upload the device image (with a new user `guest`: `sudo useradd -mU guest` and `sudo passwd guest`).

Boot Clonezilla (`start-clonezilla.sh`): for me, it worked with `Other modes of Clonezilla live` and `Clonezilla live (KMS & To RAM)`.

`device-image` -> `ssh_server` (`dhcp` server and tell it to mount `guest@10.0.2.2:/home/guest`), the image will be uploaded there.

---

Select `beginner` and `savedisk`. Select default options from there.
