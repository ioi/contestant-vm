#!/usr/bin/env python3

import os
import csv

SUBNET = '10.0.0.0/16'   # primary vpc subnet
NETMASK = '255.255.0.0'  # vpn subnet mask

DEST_DIR = 'generated_data'


def gen_tinc_conf(dir, host, peers):
    with open(dir + '/tinc.conf', 'w') as f:
        f.write(f'Name = {host}\n')
        for peer in peers:
            f.write(f'ConnectTo = {peer}\n')
        f.write('TunnelServer = yes\n')
        f.write('StrictSubnets = yes\n')


def gen_tinc_up(dir, ip):
    with open(dir + '/tinc-up', 'w') as f:
        f.write('#!/bin/bash\n\n')
        f.write(f'ifconfig $INTERFACE {ip} netmask {NETMASK}\n')
        f.write('echo 1 > /proc/sys/net/ipv4/ip_forward\n')

    os.system(f'chmod +x {dir}/tinc-up')


def gen_tinc_host(dir, host, address, ip):
    os.makedirs(dir + '/hosts', exist_ok=True)
    with open(dir + '/hosts/' + host, 'w') as f:
        if address is not None:
            f.write(f'Address = {address}\n')
            f.write(f'Subnet = {SUBNET}\n')
        f.write(f'Subnet = {ip}/32\n')

    os.system(f'tincd -c {dir} -K2048 </dev/null')


def gen_ioi_conf(dir, ip, dns_servers, server_ips):
    with open(dir + '/ip.conf', 'w') as f:
        f.write(ip)
    with open(dir + '/mask.conf', 'w') as f:
        f.write(NETMASK)
    with open(dir + '/dns.conf', 'w') as f:
        f.write(' '.join(server_ips[server] for server in dns_servers))

    if not os.path.exists(dir + '/ioibackup'):
        os.system(f'ssh-keygen -f {dir}/ioibackup -b 2048 -q -N "" -C ""')


def gen_hosts():
    server_ips = {}

    with open('./vpn_servers.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)
        for row in csv_reader:
            host, ip, address, peers = row
            server_ips[host] = ip

            dir = DEST_DIR + '/servers/' + host
            if os.path.exists(dir):
                continue

            os.makedirs(dir, exist_ok=True)

            gen_tinc_conf(dir, host, peers.split(':'))
            gen_tinc_up(dir, ip)
            gen_tinc_host(dir, host, address, ip)

    with open('./users.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)
        for row in csv_reader:
            _, _, _, _, host, _, ip, vpn_servers, _ = row

            dir = DEST_DIR + '/clients/' + host
            if os.path.exists(dir):
                continue

            os.makedirs(dir, exist_ok=True)

            gen_tinc_conf(dir, host, vpn_servers.split(':'))
            gen_tinc_host(dir, host, None, ip)
            gen_ioi_conf(dir, ip, vpn_servers.split(':'), server_ips)


def collect_hosts(type):
    dir = f'{DEST_DIR}/{type}s'
    hosts_dir = f'{DEST_DIR}/{type}_hosts'
    os.makedirs(hosts_dir, exist_ok=True)
    for host in os.listdir(dir):
        os.system(f'cp {dir}/{host}/hosts/{host} {hosts_dir}/')


def copy_hosts(to_type, from_type):
    to_dir = f'{DEST_DIR}/{to_type}s'
    from_hosts_dir = f'{DEST_DIR}/{from_type}_hosts'
    for host in os.listdir(to_dir):
        os.system(f'cp {from_hosts_dir}/* {to_dir}/{host}/hosts/')


def gen_pop_config():
    pop_config_dir = f'{DEST_DIR}/pop_config'
    os.makedirs(pop_config_dir, exist_ok=True)

    with open('./users.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)
        for row in csv_reader:
            _, _, _, _, host, password, _, _, _ = row

            pop_config_filename = f"{pop_config_dir}/{host}|{password}"
            if os.path.exists(pop_config_filename):
                continue

            os.system(f'cp -R {DEST_DIR}/clients/{host} {pop_config_dir}/vpn')
            os.system(f'tar -jcf "{pop_config_filename}" -C {pop_config_dir} vpn')
            os.system(f'rm -rf {pop_config_dir}/vpn')


def gen_backup_config():
    backup_config_dir = f'{DEST_DIR}/backup_config'
    os.makedirs(backup_config_dir, exist_ok=True)

    authorized_keys_file = f'{backup_config_dir}/authorized_keys'

    os.system(f'rm -f {authorized_keys_file}')

    with open('./users.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)

        for row in csv_reader:
            _, _, _, _, host, _, _, _, _ = row
            os.system(f'echo "command=\\\"rrsync /home/ioibackup/{host}/\\\",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding $(cat {DEST_DIR}/clients/{host}/ioibackup.pub)" >> {authorized_keys_file}')


def gen_vm_hosts():
    online_participant_ip = {}
    onsite_participant_ip = {}

    with open('./users.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)

        for row in csv_reader:
            _, _, _, _, host, _, ip, _, online = row

            if online == '1':
                online_participant_ip[host] = ip
            else:
                onsite_participant_ip[host] = ip

    with open(DEST_DIR + '/vm_hosts.ini', 'w') as f:
        for host, ip in onsite_participant_ip.items():
            f.write(f"{host} ansible_host={ip}\n")

    with open(DEST_DIR + '/vm_hosts_online.ini', 'w') as f:
        for host, ip in online_participant_ip.items():
            f.write(f"{host} ansible_host={ip}\n")


def gen_ssh_config():
    ssh_config_str = ""

    with open('./users.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)

        for row in csv_reader:
            _, _, _, _, host, _, ip, _, _ = row

            ssh_config_str += f'Host {host}\n    HostName {ip}\n    IdentityFile /home/ansible/setup/env/ssh_keys/ansible\n\n'

    with open(DEST_DIR + '/ssh_config', 'w') as f:
        f.write(ssh_config_str)


gen_hosts()

collect_hosts('server')
collect_hosts('client')

copy_hosts('server', 'server')
copy_hosts('server', 'client')
copy_hosts('client', 'server')

gen_pop_config()
gen_backup_config()
gen_vm_hosts()
gen_ssh_config()
