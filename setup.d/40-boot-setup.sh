#!/bin/bash

set -x
set -e

sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/splash//' /etc/default/grub
update-grub2

VG="ubuntu-vg"
ORIGIN_LV="ubuntu-lv"
SNAPSHOT_LV="ubuntu-snapshot"

cat <<EOM >/etc/initramfs-tools/scripts/local-premount/prompt
#!/bin/sh
PREREQ="lvm"
prereqs()
{
   echo "\$PREREQ"
}

case \$1 in
prereqs)
   prereqs
   exit 0
   ;;
esac

# Source: thicc-boiz repository from KSZK

set -e

# functions

panic()
{
  echo ""
  echo "ERROR!!!"
  echo "AUTO ROLLBACK FAILED: \${@}"
  exit 1
}

banner()
{
  echo ""
  echo "=== \${@} ==="
  echo ""
  sleep 2
}

create_snapshot()
{
  lvm lvcreate -s -p r -v -n "${SNAPSHOT_LV}" -l '100%ORIGIN' "${VG}/${ORIGIN_LV}"
}

rollback_snapshot()
{
  lvm lvconvert --mergesnapshot -v -i 2 -y "${VG}/${SNAPSHOT_LV}"
}

# main

if [ \$(lvm vgs --noheadings -o vg_name 2>/dev/null | grep "${VG}" | wc -l) -ne "1" ]; then
  panic "The presence of the volume group is dubious!"
fi

if ! lvm lvs --noheadings -o lv_name "${VG}" 2>/dev/null | grep -qs "${ORIGIN_LV}" 2>/dev/null; then
  panic "Origin LV not found!"
fi

if lvm lvs --noheadings -o lv_name "${VG}" 2>/dev/null | grep -qs "${SNAPSHOT_LV}" 2>/dev/null; then
  # Yes snapshot

  echo ""
  echo "  ==================================================="
  echo "           Press any key to attempt rollback!"
  echo "                Booting up in 15 seconds"
  echo "  ==================================================="
  echo ""

  if ! read -t 15 -n 1; then

    banner "Rollback aborted! The filesystem contents will be preserved!"
    exit 0

  fi

  # Perform rollback
  rollback_snapshot
  banner "Restoring OS and booting up"
  reboot -f
else
  # No snapshot
  banner "First boot after setting up! Will create snapshot!"

  create_snapshot
  banner "Snapshot created! Will shut down now."
  reboot -f
fi
EOM
chmod 755 /etc/initramfs-tools/scripts/local-premount/prompt

update-initramfs -uv
