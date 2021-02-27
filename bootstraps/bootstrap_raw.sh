#!/bin/sh

# Install required packages
export PKG_PATH=https://cdn.openbsd.org/pub/OpenBSD/$(uname -r)/packages/$(uname -p)
pkg_add -I ansible git jq

# Harden git config
/usr/local/bin/git config --global transfer.fsckObjects true
/usr/local/bin/git config --global receive.fsckObjects true
/usr/local/bin/git config --global fetch.fsckObjects true

# Make git folder
/bin/mkdir /root/git
cd /root/git

# Gather github.com public key
/usr/bin/ssh-keyscan -H github.com >> /root/.ssh/known_hosts

# Clone playbook
if [ -d /root/git/lappland-vpn ]
then
  cd /root/git/lappland-vpn && /usr/local/bin/git pull --rebase
else
  /usr/local/bin/git clone git@github.com:rodneylab/lappland-vpn.git
fi
