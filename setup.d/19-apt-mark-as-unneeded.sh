#!/bin/bash

set -x
set -e

# Mark some packages unneeded
# previously it was apt remove, but it was hard to maintain:
#   During migration between Ubuntu versions,
#   there were changes in dependencies,
#   and packages previously removed were uninstalled here

apt-mark auto gnome-power-manager brltty extra-cmake-modules
apt-mark auto llvm-13-dev zlib1g-dev libobjc-11-dev libx11-dev dpkg-dev manpages-dev
apt-mark auto linux-firmware memtest86+
apt-mark auto network-manager-openvpn network-manager-openvpn-gnome openvpn
apt-mark auto autoconf autotools-dev

# Remove most extra modules but preserve those for sound
# This was removed. Although the image is smaller,
# the code is harder to maintain, and it breaks migration between VMM vendors and some laptops

