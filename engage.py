#!/usr/bin/env python3 -tt
# -*- coding: utf-8 -*-
import datetime
from random import choices, randint
from contextlib import contextmanager
import os
from pathlib import Path
import string
import subprocess
import yaml


@contextmanager
def set_directory(path: Path):
    """Setd the cwd within the context

    Args:
        path (Path): The path to the cwd

    Yields:
        None
    """

    origin = Path().absolute()
    try:
        os.chdir(path)
        yield
    finally:
        os.chdir(origin)


def get_random_server_name():
    result = choices(string.ascii_lowercase, k=3)
    for i in range(0, 7):
        result.append(str(randint(0, 9)))
    print(''.join(result))
    return ''.join(result)


def get_date_string():
    return datetime.datetime.now().strftime('%Y-%m-%d')


def get_ssh_key_name():
    return './configs/id_ed25519_lappland_' + get_date_string()


def get_ssh_public_key(filename):
    f = open(filename + '.pub', 'r')
    return str(f.readlines()[0])


def load_config():
    with open(r'./config.yml') as file:
        parameters = yaml.load(file, Loader=yaml.FullLoader)
    return parameters


def main():
    parameters = load_config()
    env_copy = os.environ.copy()

    admin_account = 'lappland'
    if 'admin_account' in parameters:
        admin_account = parameters['admin_account']

    if 'server_name' in parameters:
        server_name = parameters['server_name']
    else:
        server_name = get_random_server_name()

    firewall_select_source = "0.0.0.0/0"
    if 'firewall_select_source' in parameters:
        firewall_select_source = parameters['firewall_select_source']

    if 'gcloud' in parameters:
        region = parameters['gcloud']['region']

    env_copy['LAPPLAND_ADMIN'] = admin_account
    command = ['sh', 'generate-ssh-keys.sh', get_ssh_key_name()]
    subprocess.check_call(command, env=env_copy)

    # prompt for image path
    env_copy['TF_VAR_image'] = '../openbsd-amd64-68-210227.tar.gz'
    env_copy['TF_VAR_image_name'] = 'openbsd-amd64-68-210227.tar.gz'
    env_copy['TF_VAR_image_family'] = 'openbsd-amd64-68'

    env_copy['TF_VAR_bucket'] = 'lappland-openbsd-images-' + get_date_string()
    env_copy['TF_VAR_project_id'] = os.getenv('GOOGLE_PROJECT')
    env_copy['TF_VAR_region'] = region
    env_copy['TF_VAR_server_name'] = server_name
    env_copy['TF_VAR_ssh_port'] = str(parameters['ssh_port'])
    env_copy['TF_VAR_wg_port'] = str(parameters['wg_port'])
    env_copy['TF_VAR_firewall_select_source'] = firewall_select_source
    env_copy['TF_VAR_lappland_id'] = 'lappland-b'
    env_copy['TF_VAR_ssh_key'] = admin_account + ':' \
        + get_ssh_public_key(get_ssh_key_name())

    with set_directory(Path('./terraform/gcloud')):
        subprocess.check_call(['terraform', 'init'], env=env_copy)
        subprocess.check_call(['terraform', 'apply'], env=env_copy)
        subprocess.check_call(['terraform', 'show'])
#
# in regions folder
# terraform init
# terraform apply
# terraform output -json regions > jq -r
# file is [ "asia-east1", "asia-east2", ..., "us-west4"]
# see https://cloud.google.com/compute/docs/regions-zones for name to description mapping


if __name__ == "__main__":
    main()
