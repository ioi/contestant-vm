#!/bin/bash

set -x
set -e

cp -a html /usr/share/doc/ioi
mkdir -p /usr/share/doc/ioi/fonts
$wget -O $cache/fira-sans.zip "https://gwfh.mranftl.com/api/fonts/fira-sans?download=zip&subsets=latin&variants=regular"
$wget -O $cache/share.zip "https://gwfh.mranftl.com/api/fonts/share?download=zip&subsets=latin&variants=regular"
unzip -o $cache/fira-sans.zip -d /usr/share/doc/ioi/fonts
unzip -o $cache/share.zip -d /usr/share/doc/ioi/fonts
