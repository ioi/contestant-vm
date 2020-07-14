#!/bin/sh

# Create IOI account
useradd -m ioi

# Setup desktop background
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-options 'wallpaper'
sudo -Hu ioi xvfb-run gsettings set org.gnome.desktop.background picture-uri \
    'file:///opt/ioi/misc/ioi2020-wallpaper.png'

# Update path
echo 'PATH=/opt/ioi/bin:$PATH' >> ~ioi/.bashrc

# Mark Gnome's initial setup as complete
sudo -Hu ioi bash -c 'echo yes > ~/.config/gnome-initial-setup-done'

# Autostart ioisetup
cp /opt/ioi/misc/ioisetup.desktop /usr/share/gnome/autostart

# Setup default Mozilla Firefox configuration
cp -a /opt/ioi/misc/mozilla ~ioi/.mozilla
chown -R ioi.ioi ~ioi/.mozilla
