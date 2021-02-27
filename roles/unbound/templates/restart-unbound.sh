#!/bin/sh
/usr/sbin/rcctl stop unbound
sleep 30
/usr/sbin/unbound-anchor -a /var/unbound/db/root.key -4 -v && \
  /usr/sbin/rcctl start unbound
sleep 30
RETRIES=0
until [ $RETRIES -eq 60 ] || /etc/rc.d/unbound check; do
  /etc/rc.d/unbound restart
  sleep 30
done
[ $RETRIES -lt 60 ]
