#!/bin/bash

set -x
set -e

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
# These SUID management scripts are not needed
rm /usr/local/bin/llk /usr/local/bin/llkk
cp ../keymaps/en_US_ubuntu_1204.map /opt/ioi/misc/
popd
rm -rf $WORKDIR
