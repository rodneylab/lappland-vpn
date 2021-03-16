#!/bin/sh

extra_vars=$( jq -n \
              --arg lappland_id "$TF_VAR_lappland_id" \
              --arg lappland_server_name "$TF_VAR_server_name" \
              --arg lappland_server_ip "$LAPPLAND_SERVER_IP" \
              --arg peers "$PEERS" \
              --arg ssh_private_key_file "$SSH_PRIVATE_KEY_FILE" \
              --arg admin_account "$LAPPLAND_ADMIN" \
              --arg ssh_clients "$SSH_CLIENTS" \
              --arg ssh_port "$TF_VAR_ssh_port" \
              --arg wireguard_peers "$WIREGUARD_PEERS" \
              --arg wireguard_port "$TF_VAR_wg_port" \
              --arg wireguard_server_address "$WIREGUARD_SERVER_ADDRESS" \
              --arg wireguard_subnet "$WIREGUARD_SUBNET" \
              '{
                "admin_account":$admin_account,
                "configure_phase":true,
                "lappland_id":$lappland_id,
                "lappland_server_name":$lappland_server_name,
                "lappland_server_ip":$lappland_server_ip,
                "peers":$peers,
                "ssh_port":$ssh_port,
                "ssh_clients":$ssh_clients,
                "ssh_private_key_file":$ssh_private_key_file,
                "ssh_user":$admin_account,
                "wireguard_peers":$wireguard_peers,
                "wireguard_port":$wireguard_port,
                "wireguard_server_address":$wireguard_server_address,
                "wireguard_subnet":$wireguard_subnet,
              }'
)

# Run playbook
ansible-galaxy collection install community.crypto
ansible-playbook -e @secrets_file.enc \
                 --ask-vault-pass \
                 --become-method=doas \
                 --ask-become-pass \
                 main.yml \
                 --extra-vars="$extra_vars" 2>&1 | tee -a ./server-configure.log
