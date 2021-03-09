#!/bin/sh

# Run playbook
ansible-playbook --become-method=doas \
                 --ask-become-pass \
                 ssh-secure.yml 2>&1 | tee -a ./ssh-secure.log
