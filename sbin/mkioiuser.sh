#!/bin/sh

# Create IOI account
useradd -m ioi

# Setup desktop background
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-options 'wallpaper'
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-uri \
	'file:///opt/ioi/misc/ioi2020-wallpaper.png'
sudo -Hu ioi xvfb-run gsettings set org.gnome.shell enabled-extensions "['add-username-ioi2020']"
sudo -Hu ioi xvfb-run gsettings set org.gnome.shell disable-user-extensions false
chfn -f "$FULLNAME" ioi

# Update path
echo 'PATH=/opt/ioi/bin:$PATH' >> ~ioi/.bashrc

# Mark Gnome's initial setup as complete
sudo -Hu ioi bash -c 'echo yes > ~/.config/gnome-initial-setup-done'

sudo -Hu ioi bash -c 'mkdir -p ~ioi/.config/share/gnome-shell/extensions'
cp -a misc/add-username-ioi2020 ~ioi/.local/share/gnome-shell/extensions/
chown -R ioi.ioi ~ioi/.local/share/gnome-shell/extensions/add-username-ioi2020

# IOI startup
cp /opt/ioi/misc/ioistart.desktop /usr/share/gnome/autostart/

# Setup default Mozilla Firefox configuration
cp -a /opt/ioi/misc/mozilla ~ioi/.mozilla
chown -R ioi.ioi ~ioi/.mozilla
