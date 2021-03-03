#!/bin/sh
# $1 - interface e.g. "wg0"
WIREGUARD_DIR="/etc/wireguard"
TEMPLATES_DIR=${WIREGUARD_DIR}/"templates"
PEER_TEMPLATES_DIR=${TEMPLATES_DIR}"/peers"
OUTPUT_DIR=${WIREGUARD_DIR}"/peers"
umask 077

# Generate private key
PRIVATE_KEY=$(openssl rand -base64 32)

# Create interface-specific configuration file
HOSTNAME_IF=/etc/hostname.$1
echo "wgkey ${PRIVATE_KEY} wgport {{ wireguard_port }}" > $HOSTNAME_IF
echo "inet {{ wireguard_server_address }} 255.255.255.0 NONE description \"vpn tunnel\" \n" \
  >> $HOSTNAME_IF
chmod 0640 $HOSTNAME_IF
chown root:wheel $HOSTNAME_IF

# bring up interface
/bin/sh /etc/netstart $1

# get public key
SERVER_PUBLIC_KEY=$(ifconfig $1 | grep wgpubkey | cut -d ' ' -f 2)

# Remove any existing peers
ifconfig wg0 -wgpeerall

# Generate peer keys
for peer in "${PEER_TEMPLATES_DIR}"/*; do
  OUTPUT_FILE=${OUTPUT_DIR}/$(basename $peer)
  cp $peer ${OUTPUT_FILE}
  PEER_PRIVATE_KEY=$(wg genkey)
  PEER_PUBLIC_KEY=$(echo ${PEER_PRIVATE_KEY} | wg pubkey)
  PRESHARED_KEY=$(wg genpsk)

  # Populate peer file
  sed -i 's:PRIVATE_KEY:'"$(echo ${PEER_PRIVATE_KEY})"':g' $OUTPUT_FILE
  sed -i 's:PEER_PUBLIC_KEY:'"$(echo ${SERVER_PUBLIC_KEY})"':g' $OUTPUT_FILE
  sed -i 's:PRESHARED_KEY:'"$(echo ${PRESHARED_KEY})"':g' $OUTPUT_FILE
  chown {{ admin_account }}:wheel $OUTPUT_FILE

  ## Generate peer QR code
  QR_OUTPUT_FILE="${OUTPUT_FILE%.*}".png
  qrencode -o $QR_OUTPUT_FILE < $OUTPUT_FILE
  chown {{ admin_account }}:wheel $QR_OUTPUT_FILE

  # Update interface-specific configuration file
  PEER_IP=$(cat $peer | grep Address | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}")
  echo "${PEER_IP} ${PEER_PUBLIC_KEY} ${PRESHARED_KEY}" | awk \
    '{print "wgpeer "$2" wgpsk "$3" wgaip "$1"/32\n"}' >> $HOSTNAME_IF
done

echo "!/sbin/ifconfig \$if mtu 1380" >> $HOSTNAME_IF
