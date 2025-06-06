#!/bin/bash

# Set inventory path
INVENTORY_PATH="../ansible/inventory/production.ini"

# Activate the Python virtual environment
source ansible-env/bin/activate

echo "#################################################################"
echo "Verifying Ansible inventory at: $INVENTORY_PATH"

# Ensure the inventory file exists
if [ ! -f "$INVENTORY_PATH" ]; then
    echo "Error: Inventory file not found at: $INVENTORY_PATH"
    deactivate
    exit 1
fi

echo "#################################################################"
echo "Running Ansible playbook for production deployment..."
ansible-playbook -i "$INVENTORY_PATH" ../ansible/playbooks/deploy-docker-test.yml

echo "#################################################################"

# Deactivate virtual environment
deactivate