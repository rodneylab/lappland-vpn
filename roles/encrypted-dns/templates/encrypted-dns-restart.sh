#!/bin.sh
pid=`pgrep "encrypted-dns"`
if [ ! -z "$pid" ]; then
  kill -9 $pid
fi
sleep 6
exec /usr/local/sbin/encrypted-dns --config /etc/encrypted-dns/encrypted-dns.toml
