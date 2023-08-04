#!/bin/bash

test -f ubuntu.iso || curl https://www.releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso -o ubuntu.iso

echo 'You will need to initialize shell (e.g. `init=/bin/bash` kernel parameter in GRUB)'
echo 'From this shell, run `zerofree /dev/sda2`'
qemu-system-x86_64 -display gtk -hda disk.img -cdrom ubuntu.iso -m 2048 -net nic -net user -cpu host -machine accel=kvm -boot order=d

