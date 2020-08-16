#!/bin/sh

(cat /etc/sudoers /etc/sudoers.d/* /opt/ioi/misc/VERSION; \
	grep -v ioi /etc/passwd; \
	grep -v ioi /etc/shadow ) \
	| sha256sum | cut -d\  -f1
