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

admin_account="lappland"
if [ "$instance_keys" != "" ]
then
    echo "$instance_keys" | while read line
    do
        username="$(echo $line | cut -d: -f1)"
        user_key="$(echo $line | cut -d: -f2)"
        key_comment="$(echo $line | awk '{print $NF}')"

        if [ "$username" != "" ]
        then
            admin_account=$username
        fi
    done
else
    echo "No user metadata found"
fi

# set lappland_id from metadata
lappland_id=$(/usr/local/bin/curl -s \
  --resolve metadata.google.internal:80:169.254.169.254 \
  -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/lappland-id)
if [ "$lappland_id" == "" ]
    lappland_id=lappland
fi

# get random services address
services_address="10.172.$((RANDOM % 254 + 1)).$((RANDOM % 254 + 1))"

# Extra variables for playbook
public_server_address=$(/usr/local/bin/curl -L https://diagnostic.opendns.com/myip)
public_net=$(ifconfig vio0 | grep inet | awk '{print $2}')
extra_vars=$( /usr/local/bin/jq -n \
              --arg admin_account "$admin_account" \
              --arg admin_ssh_public_key "$user_key" \
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
cd /root/git/lappland-ansible-deploy/ && /usr/local/bin/ansible-playbook \
  install.yml \
  --tag=users,system,sysctl,pf-base,dnscrypt-proxy,unbound,encrypted-dns,hardening,reboot \
  --extra-vars="$extra_vars" 2>&1 | tee -a /var/log/bootstrap
