#!/bin/bash
# This script sets up a Python virtual environment with Ansible installed.

# Start time measurement
start_time=$(date +%s)

# Check current Python version
echo "Current Python version:"
python3 --version

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python is not installed. Installing Python 3..."
    sudo apt update
    sudo apt install -y python python3-venv python3-pip python3-packaging
    sudo apt install -y python-is-python3
fi

# Create virtual environment with Python 3.11
python -m venv ansible-env

# Activate the virtual environment
source ansible-env/bin/activate

# Install Ansible in the virtual environment
pip install ansible

# Verify Ansible installation
ansible --version

echo -e "\nPython and Ansible environment is ready!"
deactivate
echo "To activate the environment, run: source ansible-env/bin/activate"


# Calculate and display execution time
end_time=$(date +%s)
duration=$((end_time - start_time))

hours=$((duration / 3600))
minutes=$(( (duration % 3600) / 60 ))
seconds=$((duration % 60))

# Format with leading zeros
printf "Duration: %02d:%02d:%02d\n" $hours $minutes $seconds
