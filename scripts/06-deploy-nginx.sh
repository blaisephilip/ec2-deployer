#!/bin/bash

# Start time measurement
start_time=$(date +%s)

# Set inventory path
INVENTORY_PATH="../ansible/inventory/production-redhat.ini"

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
ansible-playbook -i "$INVENTORY_PATH" ../ansible/playbooks/deploy-nginx.yml 
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