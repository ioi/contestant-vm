#!/bin/sh

cat /etc/sudoers \
	/etc/sudoers.d/* \
	/opt/ioi/bin/* \
	/opt/ioi/sbin/* \
	| sha256sum | cut -d\  -f1
