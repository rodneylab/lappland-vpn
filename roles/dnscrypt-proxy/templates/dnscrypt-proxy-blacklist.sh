#!/bin/sh
/usr/local/bin/curl -Lo /etc/dnscrypt-proxy/mybase.txt \
  https://download.dnscrypt.info/blacklists/domains/mybase.txt \
  && mv /etc/dnscrypt-proxy/mybase.txt \
  /etc/dnscrypt-proxy/blacklist.txt
/etc/rc.d/dnscrypt_proxy restart
sleep 30
RETRIES=0
until [ $RETRIES -eq 60 ] || /etc/rc.d/dnscrypt_proxy check; do
  /etc/rc.d/dnscrypt_proxy restart
  sleep 30
done
[ $RETRIES -lt 60 ]
