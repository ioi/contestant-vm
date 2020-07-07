#!/bin/sh

# Fix up date/time

timedatectl set-timezone Asia/Singaopre
vmware-toolbox-cmd timesync enable
hwclock -w

# Update packages

apt update
apt -y upgrade

# Convert server install into a minimuam desktop install

apt -y install tasksel
tasksel install ubuntu-desktop-minimal ubuntu-desktop-minimal-default-languages

# Install tools needed for management and monitoring

apt -y install net-tools openssh-server ansible xvfb tinc

# Install packages needed by contestants

apt -y install openjdk-8-jdk-headless codeblocks emacs \
	geany gedit joe kate kdevelop nano vim vim-gtk3 \
	ddd valgrind visualvm ruby python3-pip

# Install snap packages needed by contestants

snap install --classic atom
snap install --classic eclipse
snap install --classic intellij-idea-community
snap install --classic code

# Install python3 libraries

pip3 install matplotlib

mkdir /opt/ioi
cp -a bin misc /opt/ioi/

sed -i '/^SHELL/ s/\/sh$/\/bash/' /etc/default/useradd

# Create IOI account

useradd -m ioi
echo "ioi:ioi" | chpasswd

# Setup desktop background

sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-options 'wallpaper'
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-uri \
	'file:///opt/ioi/misc/ioi2020-wallpaper.png'

# Setup default Mozilla Firefox configuration

cp -a misc/mozilla ~ioi/.mozilla
chown -R ioi.ioi ~ioi.mozilla

# Don't list ansible user at login screen

cat - <<EOM > /var/lib/AccountsService/users/ansible
[User]
Language=
XSession=gnome
SystemAccount=true
EOM

chmod 644 /var/lib/AccountsService/users/ansible

# ADD QUIET SPLASH

sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/ s/"$/ quiet splash"/' /etc/default/grub
update-grub2

sed -i '/^SHELL/ s/\/sh$/\/bash/' /etc/default/useradd

sudo -Hu ioi bash -c 'mkdir ~/.config'
sudo -Hu ioi bash -c 'echo yes > ~/.config/gnome-initial-setup-done'

# Setup SSH authorized keys for ansible

mkdir ~/.ssh
cp misc/id_ansible.pub ~/.ssh/authorized_keys

# Documentation

apt -y install stl-manual openjdk-8-doc python3-doc

# CPP Reference

wget -O /tmp/html_book_20190607.zip http://upload.cppreference.com/mwiki/images/b/b2/html_book_20190607.zip
mkdir /opt/cppref
unzip /tmp/html_book_20190607.zip -d /opt/cppref
rm -f /tmp/html_book_20190607.zip

# Mark some packages as needed so they wont' get auto-removed

apt -y install `dpkg-query -Wf '${Package}\n' | grep linux-image-`
apt -y install `dpkg-query -Wf '${Package}\n' | grep linux-modules-`

# Remove unneeded packages

apt -y remove gnome-power-manager
apt -y llvm-9-dev
apt -y remove linux-firmware
apt -y remove memtest86+
apt -y remove network-manager-openvpn network-manager-openvpn-gnome openvpn
apt -y remove gnome-getting-started-docs-it gnome-getting-started-docs-ru \
	gnome-getting-started-docs-es gnome-getting-started-docs-fr gnome-getting-started-docs-de
apt -y remove manpages-dev
apt autoremove

apt clean

# Create local HTML

mkdir /opt/ioi/html/fonts
wget -O /tmp/fira-sans.zip "https://google-webfonts-helper.herokuapp.com/api/fonts/fira-sans?download=zip&subsets=latin&variants=regular"
wget -O /tmp/share.zip "https://google-webfonts-helper.herokuapp.com/api/fonts/share?download=zip&subsets=latin&variants=regular?"
unzip /tmp/fira-sans.zip -d /opt/ioi/html/fonts
unzip /tmp/share.zip -d /opt/ioi/html/fonts
rm /tmp/fira-sans.zip
rm /tmp/share.zip

truncate -s0 /var/log/wtmp
truncate -s0 /var/log/lastlog
rm -rf /tmp/*
rm -rf /var/tmp/*
cloud-init clean --logs
cat /dev/null ~/.bash_history && history -c
history -w

# Recreate swap file

swapoff -a
rm /swap.img
dd if=/dev/zero of=/swap.img bs=1048576 count=3908
mkswap /swap.img


