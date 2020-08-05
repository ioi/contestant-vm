#!/bin/sh

# Create IOI account
useradd -m ioi

# Setup desktop background
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-options 'wallpaper'
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-uri \
	'file:///opt/ioi/misc/ioi2020-wallpaper.png'
sudo -Hu ioi xvfb-run gsettings set org.gnome.shell enabled-extensions "['add-username-ioi2020']"
sudo -Hu ioi xvfb-run gsettings set org.gnome.shell disable-user-extensions false
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.session idle-delay 900
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.screensaver lock-delay 30
chfn -f "$FULLNAME" ioi

# Update path
echo 'PATH=/opt/ioi/bin:$PATH' >> ~ioi/.bashrc
echo "alias vpn='sudo /opt/ioi/bin/vpn.sh'" >> ~ioi/.bashrc
echo "alias ioiexec='sudo /opt/ioi/bin/ioiexec.sh'" >> ~ioi/.bashrc

# Mark Gnome's initial setup as complete
sudo -Hu ioi bash -c 'echo yes > ~/.config/gnome-initial-setup-done'

sudo -Hu ioi bash -c 'mkdir -p ~ioi/.local/share/gnome-shell/extensions'
cp -a /opt/ioi/misc/add-username-ioi2020 ~ioi/.local/share/gnome-shell/extensions/
chown -R ioi.ioi ~ioi/.local/share/gnome-shell/extensions/add-username-ioi2020

# Copy VSCode extensions
mkdir ~ioi/.vscode
cp -a /opt/ioi/misc/vscode-extensions ~ioi/.vscode/extensions

# IOI startup
cp /opt/ioi/misc/ioistart.desktop /usr/share/gnome/autostart/

# Setup default Mozilla Firefox configuration
cp -a /opt/ioi/misc/mozilla ~ioi/.mozilla
chown -R ioi.ioi ~ioi/.mozilla
