#!/bin/sh
LOG_DIR="/var/log/suricata"
min_file_size=64000
file_size=`du -k ${LOG_DIR}/eve.json | tr -s '\t' ' ' | cut -d' ' -f1`
if [ $file_size -gt $min_file_size ]; then
  timestamp=`sh -c 'date -r $(expr $(date +%s) + 3600) +%Y-%m-%d-%H-00'`

  # roll over logs
  /usr/bin/find ${LOG_DIR}/ -name "*.json" -exec \
    mv -i {} {}.$timestamp \; ;
  /usr/bin/find ${LOG_DIR}/ -name "*.log" -exec \
    mv -i {} {}.$timestamp \; ;
  rcctl restart suricata
  sleep 60
  RETRIES=0
  until [ $RETRIES -eq 60 ] || /etc/rc.d/suricata check; do
    rm -f /var/suricata/run/suricata.pid
    /etc/rc.d/suricata restart
    sleep 60
  done

  # archive historical files
  cd ${LOG_DIR}
  files_to_archive=`ls *.${timestamp}`
  tar_file="{{ lappland_id }}-suricata-log."$timestamp".tar"
  tar -cf $tar_file $files_to_archive
  chown root:wheel $tar_file
  chmod 644 $tar_file
  /usr/local/bin/xz -z $tar_file && rm $files_to_archive
fi
