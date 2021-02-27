#!/bin/sh
cd /etc/dnscrypt-wrapper/keys
dnscrypt-wrapper --gen-provider-keypair \
  --provider-name=2.dnscrypt-cert.lappland.com \
  --ext-address={{ services_address }}:443 --dnssec --nolog --nofilter
dnscrypt-wrapper --show-provider-publickey \
  --provider-publickey-file public.key > \
  "/home/{{ admin_account }}/dnscrypt-wrapper_publickey"
echo "2.dnscrypt-cert.{{ lappland_id }}.com" > provider_name
cd /etc/dnscrypt-wrapper
dnscrypt-wrapper --gen-crypt-keypair --crypt-secretkey-file=1.key
dnscrypt-wrapper --gen-cert-file --crypt-secretkey-file=1.key \
  --provider-cert-file=1.cert --provider-publickey-file=keys/public.key \
  --provider-secretkey-file=keys/secret.key
