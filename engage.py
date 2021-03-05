#!/usr/bin/env python3 -tt
# -*- coding: utf-8 -*-
import datetime
from ipaddress import IPv4Network, IPv4Address
from random import choices, getrandbits, randint
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
    return ''.join(result)


def get_date_string():
    return datetime.datetime.now().strftime('%Y-%m-%d')


def get_lappland_ip():
    # todo(rodney): add jq command here to extract ip address from
    # terraform output
    return '0.0.0.0'


def get_vpn_peers(parameters, server_address):
    wg_subnet = IPv4Network(str(server_address) + "/24", False)
    addresses_dict = {}
    peer_array = []
    if 'vpn_peers' in parameters:
        for peer in parameters['vpn_peers']:
            new_address = IPv4Address(
                wg_subnet.network_address + randint(1, 254))
            while (new_address in addresses_dict) or (
                    new_address == server_address):
                new_address = IPv4Address(
                    wg_subnet.network_address + randint(1, 254))
            peer_array.append(
                '{ "name":"'
                + peer + '", "address":"'
                + str(new_address)
                + '"}'
            )
        return '[' + ','.join(peer_array) + ']'
    else:
        print(
            '"vpn_peers" entry is missing in config file.  '
            + 'Please check the file.')
        return ''


def get_vpn_wg_server_address():
    address_range = IPv4Network("172.16.0.0/12")
    bits = getrandbits(20)

    server_address = IPv4Address(address_range.network_address + bits)
    wg_subnet = IPv4Network(str(server_address) + "/24", False)
    if ((server_address == wg_subnet) or (server_address - 255 == wg_subnet)):
        server_address = IPv4Address(
            wg_subnet.network_address + randint(1, 254))
    return str(server_address)


def get_vpn_wg_subnet(server_address):
    return str(IPv4Network(str(server_address) + "/24", False))


def get_ssh_key_name():
    return './configs/id_ed25519_lappland_' + get_date_string()


def get_ssh_public_key(filename):
    f = open(filename + '.pub', 'r')
    return str(f.readlines()[0])


def load_config():
    with open(r'./config.yml') as file:
        parameters = yaml.load(file, Loader=yaml.FullLoader)
    return parameters


def get_config_parameter(parameter_name, parameters, default):
    if parameter_name in parameters:
        return parameters[parameter_name]
    return default


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

    # todo(rodney): prompt for image path
    env_copy['TF_VAR_image'] = '../../../../openbsd-amd64-68-210227.tar.gz'
    env_copy['TF_VAR_image_name'] = 'openbsd-amd64-68-210227'
    env_copy['TF_VAR_image_file'] = 'openbsd-amd64-68-210227.tar.gz'
    env_copy['TF_VAR_image_family'] = 'openbsd-amd64-68'

    env_copy['TF_VAR_bucket'] = 'lappland-openbsd-images-2021-03-02'
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
        with open('../../terraform-plan.log', 'w') as fout:
            command = ['terraform', 'plan']
            subprocess.check_call(command, stdout=fout, env=env_copy)

        subprocess.check_call(['terraform', 'apply'], env=env_copy)
        with open('../../terraform-output.json', 'w') as fout:
            command = ['terraform', 'output', '-json']
            subprocess.check_call(command, stdout=fout, env=env_copy)

    env_copy['LAPPLAND_SERVER_IP'] = get_lappland_ip()
    env_copy['SSH_PRIVATE_KEY_FILE'] = get_ssh_key_name()
    env_copy['SSH_CLIENTS'] = get_config_parameter(
        'ssh_clients', parameters, firewall_select_source)
    env_copy['WIREGUARD_PEERS'] = get_config_parameter(
        'wireguard_peers', parameters, firewall_select_source)
    wireguard_address = get_vpn_wg_server_address()
    env_copy['WIREGUARD_SERVER_ADDRESS'] = wireguard_address
    env_copy['WIREGUARD_SUBNET'] = get_vpn_wg_subnet(wireguard_address)
    env_copy['PEERS'] = get_vpn_peers(parameters, wireguard_address)

    response = input("Do you accept wgcf Terms of Service? (yes/no) ")
    if response != 'yes':
        return

    command = ['sh', 'server.sh']
    subprocess.check_call(command, env=env_copy)


if __name__ == "__main__":
    main()
