#!/bin/bash
source ./config.sh

error() {
	local lineno="$1"
	local message="$2"
	local code="${3:-1}"
	if [[ -n "$message" ]] ; then
		echo "Error at or near line ${lineno}: ${message}; exiting with status ${code}"
	else
		echo "Error at or near line ${lineno}; exiting with status ${code}"
	fi
	exit "${code}"
}
trap 'error ${LINENO}' ERR

VERSION="test$(date +%m%d)"
ANSIBLE_PASSWD="ansible"

if [ -f "config.local.sh" ]; then
	source config.local.sh
fi

# Fix up date/time

timedatectl set-timezone Asia/Jakarta
vmware-toolbox-cmd timesync enable
hwclock -w

# Install zabbix repo
wget -O /tmp/zabbix-release_5.0-1+focal_all.deb https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i /tmp/zabbix-release_5.0-1+focal_all.deb

# Update packages

apt -y update
apt -y upgrade

# Convert server install into a minimuam desktop install

apt -y install tasksel
tasksel install ubuntu-desktop-minimal ubuntu-desktop-minimal-default-languages

# Install tools needed for management and monitoring

apt -y install net-tools openssh-server ansible xvfb tinc oathtool imagemagick \
	zabbix-agent aria2

# Install local build tools

apt -y install build-essential autoconf autotools-dev

# Install packages needed by contestants

apt -y install openjdk-11-jdk-headless codeblocks emacs \
	geany gedit joe kate kdevelop nano vim vim-gtk3 \
	ddd valgrind visualvm ruby python3-pip konsole

# Install snap packages needed by contestants

snap install --classic atom
snap install --classic code
snap install --classic sublime-text

# Install Eclipse
aria2c -x4 -d /tmp -o eclipse.tar.gz "http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2021-09/R/eclipse-java-2021-09-R-linux-gtk-x86_64.tar.gz"
tar zxf /tmp/eclipse.tar.gz -C /opt
rm /tmp/eclipse.tar.gz
wget -O /usr/share/pixmaps/eclipse.png "https://icon-icons.com/downloadimage.php?id=94656&root=1381/PNG/64/&file=eclipse_94656.png"
cat - <<EOM > /usr/share/applications/eclipse.desktop
[Desktop Entry]
Name=Eclipse
Exec=/opt/eclipse/eclipse
Type=Application
Icon=eclipse
EOM

# Install python3 libraries

pip3 install matplotlib

# Change default shell for useradd
sed -i '/^SHELL/ s/\/sh$/\/bash/' /etc/default/useradd

# Copy IOI stuffs into /opt

mkdir -p /opt/ioi
cp -a bin sbin misc /opt/ioi/
cp config.sh /opt/ioi/
mkdir -p /opt/ioi/run
mkdir -p /opt/ioi/store
mkdir -p /opt/ioi/config
mkdir -p /opt/ioi/store/log
mkdir -p /opt/ioi/store/screenshots
mkdir -p /opt/ioi/store/submissions
mkdir -p /opt/ioi/config/ssh

aria2c -x 4 -d /tmp/ -o cpptools-linux.vsix "http://mirror.nus.edu.sg/ioi2021/vscode-items/cpptools-linux.vsix"
aria2c -x 4 -d /tmp -o cpp-compile-run.vsix "http://mirror.nus.edu.sg/ioi2021/vscode-items/danielpinto8zz6.c-cpp-compile-run-1.0.11.vsix"
wget -O /tmp/vscodevim.vsix "http://mirror.nus.edu.sg/ioi2021/vscode-items/vscodevim.vim-1.16.0.vsix"
rm -rf /tmp/vscode
mkdir /tmp/vscode
mkdir /tmp/vscode-extensions
code --install-extension /tmp/cpptools-linux.vsix --extensions-dir /tmp/vscode-extensions --user-data-dir /tmp/vscode
code --install-extension /tmp/cpp-compile-run.vsix --extensions-dir /tmp/vscode-extensions --user-data-dir /tmp/vscode
tar jcf /opt/ioi/misc/vscode-extensions.tar.bz2 -C /tmp/vscode-extensions .
cp /tmp/vscodevim.vsix /opt/ioi/misc
rm -rf /tmp/vscode-extensions

# Add default timezone
echo "Asia/Jakarta" > /opt/ioi/config/timezone

# Default to enable screensaver lock
touch /opt/ioi/config/screenlock

# Create IOI account
/opt/ioi/sbin/mkioiuser.sh

# Set IOI user's initial password
echo "ioi:ioi" | chpasswd

# Fix permission and ownership
chown ioi.ioi /opt/ioi/store/submissions
chown ansible.syslog /opt/ioi/store/log
chmod 770 /opt/ioi/store/log

# Add our own syslog facility

echo "local0.* /opt/ioi/store/log/local.log" >> /etc/rsyslog.d/10-ioi.conf

# Add custom NTP to timesyncd config

cat - <<EOM > /etc/systemd/timesyncd.conf
[Time]
NTP=time.windows.com time.nist.gov
EOM

# Don't list ansible user at login screen

cat - <<EOM > /var/lib/AccountsService/users/ansible
[User]
Language=
XSession=gnome
SystemAccount=true
EOM

chmod 644 /var/lib/AccountsService/users/ansible

# GRUB config: quiet, and password for edit

sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/ s/"$/ quiet splash maxcpus=2 mem=6144M"/' /etc/default/grub
GRUB_PASSWD=$(echo -e "$ANSIBLE_PASSWD\n$ANSIBLE_PASSWD" | grub-mkpasswd-pbkdf2 | awk '/hash of / {print $NF}')

sed -i '/\$(echo "\$os" | grub_quote)'\'' \${CLASS}/ s/'\'' \$/'\'' --unrestricted \$/' /etc/grub.d/10_linux
cat - <<EOM >> /etc/grub.d/40_custom
set superusers="root"
password_pbkdf2 root $GRUB_PASSWD
EOM

update-grub2

# Setup empty SSH authorized keys and passwordless sudo for ansible

mkdir -p ~ansible/.ssh
touch ~ansible/.ssh/authorized_keys
chown -R ansible.ansible ~ansible/.ssh

sed -i '/%sudo/ s/ALL$/NOPASSWD:ALL/' /etc/sudoers
echo "ioi ALL=NOPASSWD: /opt/ioi/bin/ioiconf.sh, /opt/ioi/bin/ioiexec.sh, /opt/ioi/bin/ioibackup.sh" >> /etc/sudoers.d/01-ioi
echo "zabbix ALL=NOPASSWD: /opt/ioi/sbin/genkey.sh" >> /etc/sudoers.d/01-ioi
chmod 440 /etc/sudoers.d/01-ioi

# Documentation

apt -y install stl-manual python3-doc

# CPP Reference

wget -O /tmp/html_book_20190607.zip http://upload.cppreference.com/mwiki/images/b/b2/html_book_20190607.zip
mkdir -p /opt/cppref
unzip -o /tmp/html_book_20190607.zip -d /opt/cppref
rm -f /tmp/html_book_20190607.zip

# Build logkeys

WORKDIR=`mktemp -d`
pushd $WORKDIR
git clone https://github.com/kernc/logkeys.git
cd logkeys
./autogen.sh
cd build
../configure
make
make install
cp ../keymaps/en_US_ubuntu_1204.map /opt/ioi/misc/
popd
rm -rf $WORKDIR

# Mark some packages as needed so they wont' get auto-removed

apt -y install `dpkg-query -Wf '${Package}\n' | grep linux-image-`
apt -y install `dpkg-query -Wf '${Package}\n' | grep linux-modules-`

# Remove unneeded packages

apt -y remove gnome-power-manager brltty extra-cmake-modules
apt -y remove llvm-9-dev zlib1g-dev libobjc-9-dev libx11-dev dpkg-dev manpages-dev
apt -y remove linux-firmware memtest86+
apt -y remove network-manager-openvpn network-manager-openvpn-gnome openvpn
apt -y remove gnome-getting-started-docs-it gnome-getting-started-docs-ru \
	gnome-getting-started-docs-es gnome-getting-started-docs-fr gnome-getting-started-docs-de
apt -y remove build-essential autoconf autotools-dev
apt -y remove `dpkg-query -Wf '${Package}\n' | grep linux-header`

# Remove most extra modules but preserve those for sound
kernelver=$(uname -a | cut -d\  -f 3)
tar jcf /tmp/sound-modules.tar.bz2 -C / \
	lib/modules/$kernelver/kernel/sound/{ac97_bus.ko,pci} \
	lib/modules/$kernelver/kernel/drivers/gpu/drm/vmwgfx
apt -y remove `dpkg-query -Wf '${Package}\n' | grep linux-modules-extra-`
tar jxf /tmp/sound-modules.tar.bz2 -C /
depmod -a

# Create local HTML

cp -a html /opt/ioi/html
mkdir -p /opt/ioi/html/fonts
wget -O /tmp/fira-sans.zip "https://google-webfonts-helper.herokuapp.com/api/fonts/fira-sans?download=zip&subsets=latin&variants=regular"
wget -O /tmp/share.zip "https://google-webfonts-helper.herokuapp.com/api/fonts/share?download=zip&subsets=latin&variants=regular"
unzip -o /tmp/fira-sans.zip -d /opt/ioi/html/fonts
unzip -o /tmp/share.zip -d /opt/ioi/html/fonts
rm /tmp/fira-sans.zip
rm /tmp/share.zip

# Tinc Setup and Configuration

# Setup tinc skeleton config

mkdir -p /etc/tinc/vpn
mkdir -p /etc/tinc/vpn/hosts
cat - <<'EOM' > /etc/tinc/vpn/tinc-up
#!/bin/bash

source /opt/ioi/config.sh
ifconfig $INTERFACE "$(cat /etc/tinc/vpn/ip.conf)" netmask "$(cat /etc/tinc/vpn/mask.conf)"
route add -net $SUBNET gw "$(cat /etc/tinc/vpn/ip.conf)"
EOM
chmod 755 /etc/tinc/vpn/tinc-up
cp /etc/tinc/vpn/tinc-up /opt/ioi/misc/

cat - <<'EOM' > /etc/tinc/vpn/host-up
#!/bin/bash

source /opt/ioi/config.sh
logger -p local0.info TINC: VPN connection to $NODE $REMOTEADDRESS:$REMOTEPORT is up

# Force time resync as soon as VPN starts
systemctl restart systemd-timesyncd

# Fix up DNS resolution
resolvectl dns $INTERFACE $(cat /etc/tinc/vpn/dns.conf)
resolvectl domain $INTERFACE $DNS_DOMAIN
systemd-resolve --flush-cache

# Register something on our HTTP server to log connection
INSTANCEID=$(cat /opt/ioi/run/instanceid.txt)
wget -qO- https://$POP_SERVER/ping/$NODE-$NAME-$INSTANCEID &> /dev/null
EOM
chmod 755 /etc/tinc/vpn/host-up
cp /etc/tinc/vpn/host-up /opt/ioi/misc/

cat - <<'EOM' > /etc/tinc/vpn/host-down
#!/bin/bash

logger -p local0.info VPN connection to $NODE $REMOTEADDRESS:$REMOTEPORT is down
EOM
chmod 755 /etc/tinc/vpn/host-down

# Configure systemd for tinc
systemctl enable tinc@vpn

systemctl disable multipathd

# Disable cloud-init
touch /etc/cloud/cloud-init.disabled

# Don't stsart atd service
systemctl disable atd

# Replace atd.service file
cat - <<EOM > /lib/systemd/system/atd.service
[Unit]
Description=Deferred execution scheduler
Documentation=man:atd(8)
After=remote-fs.target nss-user-lookup.target

[Service]
ExecStartPre=-find /var/spool/cron/atjobs -type f -name "=*" -not -newercc /run/systemd -delete
ExecStart=/usr/sbin/atd -f -l 5 -b 30
IgnoreSIGPIPE=false
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOM

chmod 644 /lib/systemd/system/atd.service

# Disable virtual consoles

cat - <<EOM >> /etc/systemd/logind.conf
NAutoVTs=0
ReserveVT=0
EOM

# Disable updates

cat - <<EOM > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOM

# Use a different config for Zabbix
sed -i '/^Environment=/ s/zabbix_agentd.conf/zabbix_agentd_ioi.conf/' /lib/systemd/system/zabbix-agent.service

# Remove/clean up unneeded snaps

snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
	snap remove "$snapname" --revision="$revision"
done

rm -rf /var/lib/snapd/cache/*

# Clean up apt

apt -y autoremove

apt clean

# Remove desktop backgrounds
rm -rf /usr/share/backgrounds/*.jpg
rm -rf /usr/share/backgrounds/*.png

# Remove unwanted documentation
rm -rf /usr/share/doc/HTML
rm -rf /usr/share/doc/adwaita-icon-theme
rm -rf /usr/share/doc/alsa-base
rm -rf /usr/share/doc/cloud-init
rm -rf /usr/share/doc/cryptsetup
rm -rf /usr/share/doc/fonts-*
rm -rf /usr/share/doc/info
rm -rf /usr/share/doc/libgphoto2-6
rm -rf /usr/share/doc/libgtk*
rm -rf /usr/share/doc/libqt5*
rm -rf /usr/share/doc/libqtbase5*
rm -rf /usr/share/doc/man-db
rm -rf /usr/share/doc/manpages
rm -rf /usr/share/doc/openjdk-*
rm -rf /usr/share/doc/openssh-*
rm -rf /usr/share/doc/ppp
rm -rf /usr/share/doc/printer-*
rm -rf /usr/share/doc/qml-*
rm -rf /usr/share/doc/systemd
rm -rf /usr/share/doc/tinc
rm -rf /usr/share/doc/ubuntu-*
rm -rf /usr/share/doc/util-linux
rm -rf /usr/share/doc/wpasupplicant
rm -rf /usr/share/doc/x11*
rm -rf /usr/share/doc/xorg*
rm -rf /usr/share/doc/xproto
rm -rf /usr/share/doc/xserver*
rm -rf /usr/share/doc/xterm

# Create rc.local file
cp misc/rc.local /etc/rc.local
chmod 755 /etc/rc.local

# Set flag to run atrun.sh at first boot
touch /opt/ioi/misc/schedule2.txt.firstrun

# Embed version number
if [ -n "$VERSION" ] ; then
	echo "$VERSION" > /opt/ioi/misc/VERSION
fi

# Deny ioi user from SSH login
echo "DenyUsers ioi" >> /etc/ssh/sshd_config

echo "ansible:$ANSIBLE_PASSWD" | chpasswd

echo "### DONE ###"
echo "- Remember to run cleanup script."

# vim: ts=4
