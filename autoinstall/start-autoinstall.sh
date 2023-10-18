#!/bin/bash

set -x
set -e

if [ -z "$OVMF_PATH" ]
then
  OVMF_PATH=/usr/share/qemu/OVMF.fd
fi

# 25G -> https://bugs.launchpad.net/subiquity/+bug/1907128
qemu-img create -f qcow2 disk.img 50G
wget -c -O ubuntu.iso https://old-releases.ubuntu.com/releases/jammy/ubuntu-22.04.2-live-server-amd64.iso

# Open http server for port 8000
python3 -m http.server &
HTTP_SRV_PID=$!
trap 'kill $HTTP_SRV_PID' EXIT

# Make contestant-vm available
tar czvf contestant-vm.tar.gz --exclude autoinstall --exclude .git --exclude .github -C ../.. contestant-vm

qemu-system-x86_64 -display gtk -hda disk.img -cdrom ubuntu.iso -m 2048 -net nic -net user -cpu host -machine accel=kvm -smbios type=1,serial=ds='nocloud-net;s=http://10.0.2.2:8000/' -bios "$OVMF_PATH"
