#!/bin/sh
/usr/local/bin/oinkmaster -C /etc/oinkmaster.conf -o /etc/suricata/rules
/usr/sbin/rcctl restart suricata
