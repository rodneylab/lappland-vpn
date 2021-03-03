#!/bin/sh

extra_vars=$( jq -n \
              --arg lappland_server_name "$TF_VAR_server_name" \
              --arg lappland_server_ip "$LAPPLAND_SERVER_IP" \
              --arg peers `echo $PEERS | jq` \
              --arg ssh_private_key_file "$SSH_PRIVATE_KEY_FILE" \
              --arg ssh_user "$LAPPLAND_ADMIN" \
              --arg ssh_peers "$SSH_PEERS" \
              --arg ssh_port "$TF_VAR_ssh_port" \
              --arg wireguard_peers "$WIREGUARD_PEERS" \
              --arg wireguard_port "$TF_VAR_wg_port" \
              --arg wireguard_server_address "$WIREGUARD_SERVER_ADDRESS" \
              --arg wireguard_subnet "$WIREGUARD_SUBNET" \
              '{
                "gmail_email"
                "gmail_secret"
                "lappland_server_name":$lappland_server_name,
                "lappland_server_ip":$lappland_server_ip,
                "peers":$peers,
                "ssh_port":$ssh_port,
                "ssh_peers":$ssh_peers,
                "ssh_private_key_file":$ssh_private_key_file,
                "ssh_user":$ssh_user,
                "wireguard_peers":$wireguard_peers,
                "wireguard_port":$wireguard_port,
                "wireguard_server_address":$wireguard_server_address,
                "wireguard_subnet":$wireguard_subnet,
              }'
)

# Run playbook
ansible-playbook -e @secrets_file.asc --ask-vault-pass main.yml \
  --extra-vars="$extra_vars" 2>&1 | tee -a /var/log/bootstrap.log


