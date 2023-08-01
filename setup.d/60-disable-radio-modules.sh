#!/bin/bash

set -x
set -e

# On IOI 2023, Acer Aspire 3 notebooks are given to the contestants.
# These have an Intel i5-1135G7, a FullHD display, 8 GB of DDR4 RAM, 256 GB of NVMe SSD, ethernet port. But they also have a:
# - webcam
# - WiFi + Bluetooth card
# These are hardware components that are not needed for the contest, therefore we disable their drivers.

# YOU MIGHT NEED TO UPDATE THIS IF YOU WILL BE USING A DIFFERENT LAPTOP, OR IF THE OS CHANGES. Therefore, here is an explanation how this part of the configuration was created. Otherwise, it could have been quite magical why certain kernel modules have been disabled.

# It is important to note that it is good practice to use ethernet during a competition since it is more stable than WiFi. We will also use ethernet on IOI 2023.

# While we were trying out the notebooks, we have noticed that the WiFi + Bluetooth did not work due to problems with drivers on Linux. It is probably a feature in this case. I am sure that an update will eventually remove this "feature", therefore I am disabling the card's drivers altogether. (Check https://community.intel.com/t5/Wireless/AX101-Ubuntu-22-04-or-22-10-driver/td-p/1468063) I have tested, on Ubuntu 23.04 and I have updated the kernel to 6.4.0, and both WiFi and Bluetooth worked fine with it.
# Command `sudo dmesg` showed that there have been attempts on starting up WiFi and Bluetooth even on Ubuntu 22.04 with the current kernel (5.15.0).

# Disable webcam
# This is done in accordance with https://askubuntu.com/questions/166809/how-can-i-disable-my-webcam
echo "blacklist uvcvideo" >> /etc/modprobe.d/blacklist.conf

# To disable bluetooth, I disabled the bluetooth kernel module and everything else that depends on it (recursively). Probably disabling only one module would have been sufficient, I am not sure, I had problems if only the `bluetooth` module was disabled.

# So I ran the command `sudo lsmod | grep bluetooth`. I got:
# bluetooth             XXXXXX  XX btrtl,btintel,btbcm,bnep,btusb
# ecdh_generic           XXXXX  X bluetooth

# Therefore btrtl, btintel, btbcm, btusb depend on bluetooth, so I also wanted to disable them.
# Checking them one-by-one they didn't show any other modules.

# sudo lsmod | grep btrtl
# btrtl                  XXXXX  X btusb
# bluetooth             XXXXXX  XX btrtl,btintel,btbcm,bnep,btusb
 
# sudo lsmod | grep btintel
# btintel                XXXXX  X btusb
# bluetooth             XXXXXX  XX btrtl,btintel,btbcm,bnep,btusb
 
# sudo lsmod | grep btbcm
# btbcm                  XXXXX  X btusb
# bluetooth             XXXXXX  XX btrtl,btintel,btbcm,bnep,btusb
 
# sudo lsmod | grep bnep
# bnep                   XXXXX  X
# bluetooth             XXXXXX  XX btrtl,btintel,btbcm,bnep,btusb
 
# sudo lsmod | grep btusb
# btusb                  XXXXX  X
# btrtl                  XXXXX  X btusb
# btbcm                  XXXXX  X btusb
# btintel                XXXXX  X btusb
# bluetooth             XXXXXX  XX btrtl,btintel,btbcm,bnep,btusb

# I have also disabled the bluetooth service for good measure.

# Disable bluetooth
echo "blacklist btusb" >> /etc/modprobe.d/blacklist.conf
echo "blacklist btrtl" >> /etc/modprobe.d/blacklist.conf
echo "blacklist btbcm" >> /etc/modprobe.d/blacklist.conf
echo "blacklist btintel" >> /etc/modprobe.d/blacklist.conf
echo "blacklist bluetooth" >> /etc/modprobe.d/blacklist.conf 	
systemctl disable bluetooth.service

# From dmesg I got a hint that the WiFi card's kernel module is `iwlwifi`. Then I have went it with the exact same method as in bluetooth (described above).
# Disable wifi
echo "blacklist iwlwifi" >> /etc/modprobe.d/blacklist.conf
echo "blacklist iwlmvm" >> /etc/modprobe.d/blacklist.conf
echo "blacklist cfg80211" >> /etc/modprobe.d/blacklist.conf
echo "blacklist mac80211" >> /etc/modprobe.d/blacklist.conf
echo "blacklist libarc4" >> /etc/modprobe.d/blacklist.conf
