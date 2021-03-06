#!/bin/sh
TEMP_FILE="/var/unbound/etc/zone-block-general.conf."$(date +"%Y%m%d")
url=https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts
whitelist=/var/unbound/etc/whitelist.txt

if [ ! -f "/var/unbound/etc/zone-block-general.conf" ]; then
    touch /var/unbound/etc/zone-block-general.conf
    chown root:wheel /var/unbound/etc/zone-block-general.conf
    chmod 644 /var/unbound/etc/zone-block-general.conf
fi

(/usr/local/bin/curl --ssl-reqd $url | grep '^0\.0\.0\.0' | sort) \
  | awk '{print "\tlocal-zone: \""$2"\" refuse"}' > $TEMP_FILE
if [[ ! -s $TEMP_FILE ]]; then
  printf "Error: empty file: "$TEMP_FILE"\n"; exit 1
fi

# comment out lines containing whitelist entries
for host in $(cat $whitelist); do
  printf " $host\n"
  sed -i '/'"$(echo $host)"'/s/^/#/' $TEMP_FILE
done

cp $TEMP_FILE /var/unbound/etc/zone-block-general.conf
/usr/sbin/rcctl reload unbound
rm $TEMP_FILE 2>/dev/null
