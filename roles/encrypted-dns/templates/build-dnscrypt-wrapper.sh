#!/bin/sh
if [ ! -d /root/git ]
then
  /bin/mkdir /root/git
fi

cd /root/git
/usr/local/bin/git clone https://github.com/cofyc/dnscrypt-wrapper.git
cd dnscrypt-wrapper
/usr/local/bin/gmake LDFLAGS='-L/usr/local/lib/' CFLAGS=-I/usr/local/include/
/usr/local/bin/gmake LDFLAGS='-L/usr/local/lib/' CFLAGS=-I/usr/local/include/ install
