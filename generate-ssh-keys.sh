#!/usr/bin/env bash
mkdir ./configs
chmod 700 ./configs
ssh-keygen -a 256 -t ed25519 -f ${1} \
  -C ${LAPPLAND_ADMIN}
