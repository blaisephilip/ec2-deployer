#!/bin/bash
# This script verifies the Ansible inventory and tests connectivity to all hosts.

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

# List inventory contents
ansible-inventory -i "$INVENTORY_PATH" --list

# Test connectivity
echo "Testing connectivity to all hosts..."
ansible all -i "$INVENTORY_PATH" -m ping

echo "#################################################################"

# Deactivate virtual environment
deactivate