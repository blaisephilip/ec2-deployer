# Check current Python version
Write-Host "Current Python version:"
python --version

# Create virtual environment with Python 3.11 (recommended for Ansible)
py -3.11 -m venv ansible-env

# Activate the virtual environment
.\ansible-env\Scripts\activate

# Install Ansible in the virtual environment
pip install ansible
# Verify Ansible installation
ansible --version
Write-Host "`nPython and Ansible environment is ready!"