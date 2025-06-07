#!/bin/bash
# This script verifies the Ansible inventory and tests connectivity to all hosts.

# Start time measurement
start_time=$(date +%s)

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

# Calculate and display execution time
end_time=$(date +%s)
duration=$((end_time - start_time))

hours=$((duration / 3600))
minutes=$(( (duration % 3600) / 60 ))
seconds=$((duration % 60))

# Format with leading zeros
printf "Duration: %02d:%02d:%02d\n" $hours $minutes $seconds