#!/usr/local/bin/bash

KEYS_DIR="/etc/dnscrypt-wrapper/keys"
STKEYS_DIR="${KEYS_DIR}/short-term"
LISTS_DIR="/etc/dnscrypt-wrapper/lists"
LOGDIR="/var/log/dnscrypt-wrapper"
LOGFILE="$LOGDIR/dnscrypt-wrapper.log"
BLACKLIST="${LISTS_DIR}/blacklist.txt"

mkdir -p "$LOGDIR"

provider_name=$(cat "$KEYS_DIR/provider_name")

[ -r "$BLACKLIST" ] && blacklist_opt="--blacklist-file=${BLACKLIST}"

getpids () {
  # Grabs PIDs of existing dnscrypt-wrapper so they can be killed
  pids=`pgrep "(dnscrypt-wrapper)"`
  echo $(date +'%Y-%m-%d %H:%M:%S') current pid: $pids >> $LOGFILE
}

killpids () {
  # Kills the pids found by getpids
  if [ ! -z "$pids" ]; then
	kill -9 $pids
	echo $(date +'%Y-%m-%d %H:%M:%S') killing pid: $pids >> $LOGFILE
  fi
}

prune() {
  echo $(date +'%Y-%m-%d %H:%M:%S') pruning old st keys and certs >> $LOGFILE
  /usr/bin/find "$STKEYS_DIR" -type f -cmin +1440 -exec rm -f {} \;
}

rotation_needed() {
	if [ $(/usr/bin/find "$STKEYS_DIR" -name '*.cert' -type f -cmin -360 -print | /usr/bin/wc -l | /usr/bin/sed 's/[^0-9]//g') -le 0 ]; then
		echo true
	else
		echo false
	fi
}

new_key() {
	echo $(date +'%Y-%m-%d %H:%M:%S') generating new st key >> $LOGFILE
	ts=$(date '+%s')
	/usr/local/sbin/dnscrypt-wrapper --gen-crypt-keypair \
		--crypt-secretkey-file="${STKEYS_DIR}/${ts}.key" &&
	/usr/local/sbin/dnscrypt-wrapper --gen-cert-file \
		--provider-publickey-file=${KEYS_DIR}/public.key \
		--provider-secretkey-file=${KEYS_DIR}/secret.key \
		--crypt-secretkey-file=${STKEYS_DIR}/${ts}.key \
		--provider-cert-file=${STKEYS_DIR}/${ts}.cert \
		--cert-file-expire-days=1

	[ $? -ne 0 ] && rm -f "${STKEYS_DIR}/${ts}.key" "${STKEYS_DIR}/${ts}.cert"
}

start_new_wrapper() {
  echo $(date +'%Y-%m-%d %H:%M:%S') new wrapper starting >> $LOGFILE
  exec /usr/local/sbin/dnscrypt-wrapper \
	--daemonize \
	--listen-address={{ unbound_address }}:443 \
		--resolver-address=127.0.0.1:53 \
	--provider-name="$provider_name" \
	--provider-cert-file="$(stcerts_files)" \
	--crypt-secretkey-file=$(stkeys_files) \
	$blacklist_opt
}

stkeys_files() {
	res=""
	for file in $(ls "$STKEYS_DIR"/[0-9]*[0-9].key); do
		res="${res}${file},"
	done
	echo $(date +'%Y-%m-%d %H:%M:%S') current st keys: $res >> $LOGFILE
	echo "$res"
}

stcerts_files() {
	res=""
	for file in $(ls "$STKEYS_DIR"/[0-9]*[0-9].cert); do
		res="${res}${file},"
	done
	echo $(date +'%Y-%m-%d %H:%M:%S') current st certs: $res >> $LOGFILE
	echo "$res"
}
