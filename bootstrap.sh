#!/usr/bin/bash

SSH_KEY='ansibletest'
SSH_COMMENT='wallace@conorwithonen.com'

if [ ! -d ./venv ]; then
  echo "Creating virtual environment"
  python3 -m venv venv && source venv/bin/activate
  pip install -r requirements.txt
fi

if [ ! -e ./ssh/$SSH_KEY ];then
  echo "No SSH found. Creating one"
  ssh-keygen -t ed25519 -b 4096 -C $SSH_COMMENT -N '' -f ./ssh/$SSH_KEY
fi

# clear up existing inventory files
echo "Cleaning up old inventory files"
rm -f inventory/*.yml

# spin up fake hosts
docker compose up -d

# Get ips and generates inventory files from docker config using venv's python
$(which python) ./get_inventory.py

echo "Ansible test provisioned..."
ansible-playbook -i inventory/ playbooks/base.yml
