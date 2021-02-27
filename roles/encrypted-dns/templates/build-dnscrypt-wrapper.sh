#!/bin/sh
if [ ! -d /root/git ]
then
  /bin/mkdir /root/git
fi

cd /root/git
git clone https://github.com/cofyc/dnscrypt-wrapper.git
cd dnscrypt-wrapper
gmake LDFLAGS='-L/usr/local/lib/' CFLAGS=-I/usr/local/include/
gmake LDFLAGS='-L/usr/local/lib/' CFLAGS=-I/usr/local/include/ install
