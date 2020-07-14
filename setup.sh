#!/bin/sh

# Fix up date/time

timedatectl set-timezone Asia/Singapore
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

# Update path

echo 'PATH=/opt/ioi/bin:$PATH' >> ~ioi/.bashrc
# Autostart ioisetup

cp misc/ioisetup.desktop /usr/share/gnome/autostart

# Setup default Mozilla Firefox configuration

cp -a misc/mozilla ~ioi/.mozilla
chown -R ioi.ioi ~ioi/.mozilla

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

# Mark Gnome's initial setup as complete
sudo -Hu ioi bash -c 'echo yes > ~/.config/gnome-initial-setup-done'

# Setup SSH authorized keys and passwordless sudo for ansible

mkdir ~ansible/.ssh
cp misc/id_ansible.pub ~ansible/.ssh/authorized_keys
chown -R ansible.ansible ~ansible/.ssh

sed -i '/%sudo/ s/ALL$/NOPASSWD:ALL/' /etc/sudoers
echo "ioi ALL=NOPASSWD: /opt/ioi/bin/tinc.sh, /opt/ioi/bin/vpn.sh" >> /etc/sudoers.d/01-ioi
chmod 440 /etc/sudoers.d/01-ioi

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
apt -y autoremove

apt clean

# Create local HTML

cp -a html /opt/ioi/html
mkdir -p /opt/ioi/html/fonts
wget -O /tmp/fira-sans.zip "https://google-webfonts-helper.herokuapp.com/api/fonts/fira-sans?download=zip&subsets=latin&variants=regular"
wget -O /tmp/share.zip "https://google-webfonts-helper.herokuapp.com/api/fonts/share?download=zip&subsets=latin&variants=regular"
unzip /tmp/fira-sans.zip -d /opt/ioi/html/fonts
unzip /tmp/share.zip -d /opt/ioi/html/fonts
rm /tmp/fira-sans.zip
rm /tmp/share.zip

# Tinc Setup and Configuration

# Setup tinc skeleton config

mkdir /etc/tinc/vpn
mkdir /etc/tinc/vpn/hosts
cat - <<'EOM' > /etc/tinc/vpn/tinc-up
#!/bin/sh

ifconfig $INTERFACE "$(cat /etc/tinc/vpn/ip.conf)" netmask "$(cat /etc/tinc/vpn/mask.conf)"
route add -net 172.31.0.0/16 gw "$(cat /etc/tinc/vpn/ip.conf)"
EOM
chmod 755 /etc/tinc/vpn/tinc-up

# Configure systemd for tinc
systemctl enable tinc@vpn

# vim: ts=4
