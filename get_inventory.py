#!/home/conor/projects/venv/bin/python
import subprocess
import json

network_name = "ansible_default"

containers = []
inventory_file_data = []

def capture_shell_command_output(command):
    result = subprocess.run(command, capture_output=True, text=True, shell=True)
    output = result.stdout.strip()
    return output

# Main
# Network stuff for ip
cmd = f'docker inspect {network_name}'
network_details = capture_shell_command_output(cmd)

# compose services for host groups
cmd = f'docker compose ps --services'
docker_services = capture_shell_command_output(cmd)
network_data = json.loads(network_details)[0]
host_groups = docker_services.split('\n')

# Object
container_hash = network_data.get('Containers')

for id,data in container_hash.items():
    containers.append(data)

# Separate by hosts
for group in host_groups:
    k = 'IPv4Address'
    _ips = [c.get(k) for c in containers if group in c.get('Name')]
    ips = [i[:-3] for i in _ips]
    inventory_file_data.append({group: ips})

# Writing the file or whatever
for _inventory in inventory_file_data:
    host = next(iter(_inventory))
    ips = _inventory.get(host)
    lines = []
    print(f'Creating {host} inventory file with {len(ips)} ips...')
    # The actual write
    with open(f'./inventory/{host}.yml', 'w') as outfile:
        lines.append(f'{host}:')
        lines.append(f'  hosts:')
        # Specific Hosts
        for i in ips:
            lines.append(f'    {i}:')
        # TODO: Remove var boilerplate
        lines.append(f'  vars:')
        lines.append(f'    ansible_ssh_private_key_file: ./ssh/ansibletest')
        lines.append(f'    ansible_user: ansible')

        outfile.writelines('\n'.join(lines))



