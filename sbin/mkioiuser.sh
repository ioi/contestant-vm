#!/bin/sh

logger -p local0.info "MKIOIUSER: Create a new IOI user"

# Create IOI account
useradd -m ioi

# Setup desktop background
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-options 'centered'
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-uri \
	'file:///opt/ioi/misc/ioi-wallpaper.png'
sudo -Hu ioi xvfb-run gsettings set org.gnome.shell enabled-extensions "['add-username-ext', 'stealmyfocus-ext']"
sudo -Hu ioi xvfb-run gsettings set org.gnome.shell disable-user-extensions false
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.session idle-delay 900
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.screensaver lock-delay 30
if [ -f /opt/ioi/config/screenlock ]; then
	sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.screensaver lock-enabled true
else
	sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.screensaver lock-enabled false
fi

# set default fullname and shell
chfn -f "IOI Contestant" ioi
chsh -s /bin/bash ioi

# Update path
echo 'PATH=/opt/ioi/bin:$PATH' >> ~ioi/.bashrc
echo "alias ioiconf='sudo /opt/ioi/bin/ioiconf.sh'" >> ~ioi/.bashrc
echo "alias ioiexec='sudo /opt/ioi/bin/ioiexec.sh'" >> ~ioi/.bashrc
echo "alias ioibackup='sudo /opt/ioi/bin/ioibackup.sh'" >> ~ioi/.bashrc
echo 'TZ=$(cat /opt/ioi/config/timezone)' >> ~ioi/.profile
echo 'export TZ' >> ~ioi/.profile

# Mark Gnome's initial setup as complete
sudo -Hu ioi bash -c 'mkdir -p ~/.config'
sudo -Hu ioi bash -c 'echo yes > ~/.config/gnome-initial-setup-done'

sudo -Hu ioi bash -c 'mkdir -p ~ioi/.local/share/gnome-shell/extensions'
cp -a /opt/ioi/misc/add-username-ext ~ioi/.local/share/gnome-shell/extensions/
cp -a /opt/ioi/misc/stealmyfocus-ext ~ioi/.local/share/gnome-shell/extensions/
chown -R ioi.ioi ~ioi/.local/share/gnome-shell/extensions/add-username-ext
chown -R ioi.ioi ~ioi/.local/share/gnome-shell/extensions/stealmyfocus-ext

# Copy VSCode extensions
mkdir -p ~ioi/.vscode/extensions
tar jxf /opt/ioi/misc/vscode-extensions.tar.bz2 -C ~ioi/.vscode/extensions
chown -R ioi.ioi ~ioi/.vscode

# IOI startup
cp /opt/ioi/misc/ioistart.desktop /usr/share/gnome/autostart/

# Setup default Mozilla Firefox configuration
cp -a /opt/ioi/misc/mozilla ~ioi/.mozilla
chown -R ioi.ioi ~ioi/.mozilla

logger -p local0.info "MKIOIUSER: IOI user created"
