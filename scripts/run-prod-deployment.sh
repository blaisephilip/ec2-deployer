#!/bin/bash

# Set inventory path
INVENTORY_PATH="../ansible/inventory/production.ini"

# Activate the Python virtual environment
source ansible-env/bin/activate

cd ../ansible
echo "#################################################################"
echo "Running Ansible playbook for production deployment..."
ansible-playbook -i inventory/production.ini playbooks/deploy-docker.yml
cd ../scripts
echo "#################################################################"

# Deactivate virtual environment
deactivate