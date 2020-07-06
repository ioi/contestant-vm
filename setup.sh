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

# Remove unneeded packages

apt -y remove gnome-power-manager

# Install tools needed for management and monitoring

apt -y install net-tools openssh-server ansible xvfb

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

swapoff -a
mkswap /swap.img

