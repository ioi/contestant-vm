#!/bin/sh

set -x
set -e

if [ -z "$OVMF_PATH" ]
then
  OVMF_PATH=/usr/share/qemu/OVMF.fd
fi

wget -c -O clonezilla.iso https://kumisystems.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.1.0-22/clonezilla-live-3.1.0-22-amd64.iso

qemu-system-x86_64 -display gtk -hda disk.img -cdrom clonezilla.iso -m 2048 -net nic -net user -cpu host -machine accel=kvm -boot order=d -bios "$OVMF_PATH"
