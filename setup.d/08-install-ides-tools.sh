#!/bin/bash

set -x
set -e

apt -y install emacs \
	geany gedit joe kate kdevelop nano vim vim-gtk3 \
	ddd valgrind ruby python3-pip konsole \
	cmake

apt -y install firefox

# Install atom's latest stable version
$wget -O $cache/atom-1.60.0.deb https://github.com/atom/atom/releases/download/v1.60.0/atom-amd64.deb
dpkg -i $cache/atom-1.60.0.deb
apt -f install
# Fix #11: Atom crashes when trying to open folders
sed 's/^Exec=.*$/& --no-sandbox/' -i /usr/share/applications/atom.desktop

snap install --classic code
snap install --classic sublime-text
snap install --classic nvim

# Install Eclipse
$wget "https://mirror.dkm.cz/eclipse/technology/epp/downloads/release/2023-06/R/eclipse-cpp-2023-06-R-linux-gtk-x86_64.tar.gz"
tar zxf $cache/eclipse-cpp-2023-06-R-linux-gtk-x86_64.tar.gz -C /opt
cp /opt/eclipse/plugins/org.eclipse.epp.package.cpp_4.28.0.20230608-1200/eclipse256.png /usr/share/pixmaps/eclipse.png
cat - <<EOM > /usr/share/applications/eclipse.desktop
[Desktop Entry]
Name=Eclipse
Exec=/opt/eclipse/eclipse
Type=Application
Icon=eclipse
EOM

sed -i '/^-vmargs/a \-Dorg.eclipse.oomph.setup.donate=false' /opt/eclipse/eclipse.ini # According to https://www.eclipse.org/forums/index.php/t/1104324/ ; see: https://github.com/ioi-2023/contestant-vm/issues/21

# Install python3 libraries

pip3 install matplotlib

# Install VSCode-related stuff

# Latest as of 2023-07-23
$wget -O $cache/cpptools-1.16.3.vsix "https://github.com/microsoft/vscode-cpptools/releases/download/v1.16.3/cpptools-linux.vsix"
$wget "https://github.com/VSCodeVim/Vim/releases/download/v1.25.2/vim-1.25.2.vsix"
$wget "https://github.com/kasecato/vscode-intellij-idea-keybindings/releases/download/v1.5.9/intellij-idea-keybindings-1.5.9.vsix"
rm -rf /tmp/vscode
mkdir /tmp/vscode
mkdir /tmp/vscode-extensions
code --install-extension $cache/cpptools-1.16.3.vsix --extensions-dir /tmp/vscode-extensions --user-data-dir /tmp/vscode
tar jcf /opt/ioi/misc/vscode-extensions.tar.bz2 -C /tmp/vscode-extensions .
cp $cache/vim-1.25.2.vsix /opt/ioi/misc/extra-vsc-exts/vscodevim.vsix
cp $cache/intellij-idea-keybindings-1.5.9.vsix /opt/ioi/misc/extra-vsc-exts/intellij-idea-keybindings.vsix
rm -rf /tmp/vscode-extensions

