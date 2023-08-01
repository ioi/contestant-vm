#!/bin/bash

set -x
set -e

# Mark some packages as needed so they wont' get auto-removed

apt -y install `dpkg-query -Wf '${Package}\n' | grep linux-image-`
apt -y install `dpkg-query -Wf '${Package}\n' | grep linux-modules-`

# Mark g++ as explicitly needed

apt -y install g++
