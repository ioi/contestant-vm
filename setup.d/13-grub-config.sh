#!/bin/bash

set -x
set -e

# GRUB config: quiet, and password for edit

sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/ s/"$/ quiet splash"/' /etc/default/grub
GRUB_PASSWD=$(echo -e "$ANSIBLE_PASSWD\n$ANSIBLE_PASSWD" | grub-mkpasswd-pbkdf2 | awk '/hash of / {print $NF}')

sed -i '/\$(echo "\$os" | grub_quote)'\'' \${CLASS}/ s/'\'' \$/'\'' --unrestricted \$/' /etc/grub.d/10_linux
cat - <<EOM >> /etc/grub.d/40_custom
set superusers="root"
password_pbkdf2 root $GRUB_PASSWD
EOM

update-grub2
