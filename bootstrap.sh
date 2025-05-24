#!/usr/bin/bash
if [ ! -d ./venv ]; then
  python3 -m venv venv && source venv/bin/activate
  pip install -r requirements.txt
fi

# clear up existing inventory files
echo "Cleaning up old inventory files"
rm -f inventory/*.yml

# spin up fake hosts
docker compose up -d

# Get ips and generates inventory files from docker config
./get_inventory.py

echo "Ansible test provisioned..."
echo "Run ansible-playbook -i inventory/ playbook-add.yml to get started"
