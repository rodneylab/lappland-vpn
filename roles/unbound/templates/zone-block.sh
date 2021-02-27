#!/bin/sh
TEMP_FILE="/var/unbound/etc/unbound_hosts.conf."$(date +"%Y%m%d")
url=https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts
whitelist=/var/unbound/etc/whitelist.txt

if [ ! -f "/var/unbound/etc/unbound_hosts.conf" ]; then
    touch /var/unbound/etc/unbound_hosts.conf
    chown root:wheel /var/unbound/etc/unbound_hosts.conf
    chmod 644 /var/unbound/etc/unbound_hosts.conf
fi

/usr/local/bin/curl --ssl-reqd $url | grep '^0\.0\.0\.0' | awk \
  '{print "\tlocal-zone: \""$2"\" redirect\n\tlocal-data: \""$2" A 0.0.0.0\""}' \
  > $TEMP_FILE
if [[ ! -s $TEMP_FILE ]]; then
  printf "Error: empty file: "$TEMP_FILE"\n"; exit 1
fi

# comment out lines containing whitelist entries
for host in $(cat $whitelist); do
  printf " $host\n"
  sed -i '/'"$(echo $host)"'/s/^/#/' $TEMP_FILE
done

cp $TEMP_FILE /var/unbound/etc/unbound_hosts.conf
/usr/sbin/rcctl reload unbound
rm $TEMP_FILE 2>/dev/null
