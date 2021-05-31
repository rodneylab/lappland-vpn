#!/bin/sh
PF_WORKING_DIR="/etc/pf"
ASNS_DIR="${PF_WORKING_DIR}"/asns
BLOCK_ASNS_DIR="${PF_WORKING_DIR}"/block-asns
OUTPUT_DIR="${PF_WORKING_DIR}"/output
blocklist="${OUTPUT_DIR}"/blocklist.$(date +%F)
custom="${OUTPUT_DIR}"/custom.$(date +%F)
threats="${OUTPUT_DIR}"/threats.$(date +%F)
zones="${OUTPUT_DIR}"/zones.$(date +%F)
aws="${OUTPUT_DIR}"/aws.$(date +%F)
cloudflare="${OUTPUT_DIR}"/cloudflare.$(date +%F)
google="${OUTPUT_DIR}"/google.$(date +%F)
netflix="${OUTPUT_DIR}"/netflix.$(date +%F)

create_table_file_from_asns_file () {
  # function to create a pf table from an asns file
  # $1 path to table_file
  # $2 asns file
  rm $1 2>/dev/null
  for nb in $(grep -v "^#" $2); do
    printf " $nb"
    whois -h whois.radb.net !g$nb | tr " " "\n" | \
      grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]+" >> $1
  done
  printf "\n"
  wc -l $1
}

create_table_file_from_asns_folder () {
  for asn_file in "$2"/*; do
    printf "    $asn_file\n"
    create_table_file_from_asns_file $1 $asn_file
  done
}

# Create threats file
rm $threats 2>/dev/null
touch $threats
/usr/local/bin/curl -sq \
  "https://pgl.yoyo.org/adservers/iplist.php?ipformat=&showintro=0&mimetype=plaintext" \
  "https://www.binarydefense.com/banlist.txt" \
  "https://rules.emergingthreats.net/blockrules/compromised-ips.txt" \
  "https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt" \
  "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset" \
  "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset" \
  "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level3.netset" \
  "https://isc.sans.edu/api/threatlist/shodan/shodan.txt" | \
  grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
  grep -Ev "192.168.0.0|10.0.0.0|172.16.0.0|127.0.0.0|0.0.0.0" > $threats
wc -l $threats

# Create zones file
rm $zones 2>/dev/null
touch $zones
for zone in $(grep -v "^#" ${PF_WORKING_DIR}/zones | sed "s/\ \ \#.*//g") ; do
  printf " $zone"
  /usr/local/bin/curl -sq \
    https://www.ipdeny.com/ipblocks/data/countries/$zone.zone >> $zones
done
printf "\n"
if [ ! -s $zones ]
then
  rm -f $zones
  zones=$(find ${OUTPUT_DIR} -name zones.\* -maxdepth 1 | sort -V | tail -n 1)
fi
wc -l $zones

# Create custom file
rm $custom 2>/dev/null
touch $custom
create_table_file_from_asns_folder "$custom" "$BLOCK_ASNS_DIR"
printf "\n"
wc -l $custom

# Create blocklist file
if [ -s $threats ] && [ -s $zones ]; then
  sort $threats $custom $zones | uniq > $blocklist
  wc -l $blocklist
  # if [[ ! -s $blocklist ]]; then
  #   printf "Error empty file: "$blocklist"\n"; exit 1
  # fi
  cp $blocklist /etc/pf/blocklist
fi

# Create cloudflare table
create_table_file_from_asns_file "$cloudflare" "${ASNS_DIR}/cloudflare"
cp $cloudflare /etc/pf/cloudflare-ip-list

# Create aws table
create_table_file_from_asns_file "$aws" "${ASNS_DIR}/aws"
cp $aws /etc/pf/aws-ip-list

# Create google table
create_table_file_from_asns_file "$google" "${ASNS_DIR}/google"
cp $google /etc/pf/google-ip-list

# Create netflix table
create_table_file_from_asns_file "$netflix" "${ASNS_DIR}/netflix"
cp $netflix /etc/pf/netflix-ip-list

# Flush all existing tables in the pf.rules anchor
pfctl -a pf.rules -F Tables

# Reload the anchor
pfctl -a pf.rules -f /etc/pf.anchors/pf.rules

# Print summaries
printf "Entries in aws table:\n"
pfctl -a pf.rules -t aws-ip-list -T show | wc -l
printf "Entries in cloudflare table:\n"
pfctl -a pf.rules -t cloudflare-ip-list -T show | wc -l
printf "Entries in google table:\n"
pfctl -a pf.rules -t google-ip-list -T show | wc -l
printf "Entries in netflix table:\n"
pfctl -a pf.rules -t netflix-ip-list -T show | wc -l
printf "Entries in blocklist table:\n"
pfctl -a pf.rules -t blocklist -T show | wc -l
