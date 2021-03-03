#!/bin/sh

# bootstrap the system
/usr/local/bin/curl -L \
  https://raw.githubusercontent.com/rodneylab/lappland-vpn/main/bootstraps/bootstrap_raw.sh \
  | sh

# get admin username
instance_keys=$(/usr/local/bin/curl -s \
  --resolve metadata.google.internal:80:169.254.169.254 \
  -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/ssh-keys)

get_admin_username () {
  if [ -z "$1" ]; then
    echo "lappland"
  else
    echo "$1" | while read line
  do
    username="$(echo $line | cut -d: -f1)"
    echo $username
  done
  fi
}

get_public_key () {
  if [ -z "$1" ]; then
    echo ""
  else
    echo "$1" | while read line
  do
    user_key="$(echo $line | cut -d: -f2)"
    echo $user_key
  done
fi
}

admin_account=$(get_admin_username "$instance_keys")
admin_ssh_public_key=$(get_public_key "$instance_keys")

# set lappland_id from metadata
lappland_id=$(/usr/local/bin/curl -s \
  --resolve metadata.google.internal:80:169.254.169.254 \
  -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/lappland-id)
if [ "$lappland_id" == "" ]
then
    lappland_id=lappland
fi

# get random services address
services_address="10.172.$((RANDOM % 254 + 1)).$((RANDOM % 254 + 1))"

# Extra variables for playbook
public_server_address=$(/usr/local/bin/curl -L https://diagnostic.opendns.com/myip)
public_net=$(ifconfig vio0 | grep inet | awk '{print $2}')
extra_vars=$( /usr/local/bin/jq -n \
              --arg admin_account "$admin_account" \
              --arg admin_ssh_public_key "$admin_ssh_public_key" \
              --arg lappland_id "$lappland_id" \
              --arg pub_add "$public_server_address" \
              --arg pub_net "$public_net" \
              --arg services_address "$services_address" \
              '{
                "admin_account":$admin_account,
                "admin_ssh_public_key":$admin_ssh_public_key,
                "lappland_id":$lappland_id,
                "public_net":$pub_net,
                "public_server_address":$pub_add,
                "role_sysctl_task":"router_sysctl",
                "services_address":$services_address,
                "ssh_port":"1551",
              }'
)

# Run playbook
cd /root/git/lappland-vpn/ && /usr/local/bin/ansible-playbook \
  install.yml \
  --tag=users,system,sysctl,pf-base,dnscrypt-proxy,unbound,encrypted-dns,hardening,reboot \
  --extra-vars="$extra_vars" 2>&1 | tee -a /var/log/bootstrap && \
  touch "/var/log/lappland-result.json"

