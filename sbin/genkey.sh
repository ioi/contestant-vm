#!/bin/sh

logger -p local0.info "GENKEY: invoked"

(cat /etc/sudoers /etc/sudoers.d/* /opt/ioi/misc/VERSION; \
	grep -v ioi /etc/passwd; \
	grep -v ioi /etc/shadow ) \
	| sha256sum | cut -d\  -f1
