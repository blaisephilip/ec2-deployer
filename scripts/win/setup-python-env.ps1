# Check current Python version
Write-Host "Current Python version:"
python --version

# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python is not installed. An installation attempt will be made."
    # Attempt to install Python using the Microsoft Store
    # Test if the OS is Windows

        # Check if OS is Ubuntu 
    if ($IsUbuntu) {
        Write-Host "Install python as APT package"
        Write-Host "The Python 3.11 is necessary. Execute the following commands to install it:"
        Write-Host "sudo apt update"
        Write-Host "sudo apt install python3 python3-venv pip"
        Write Host "sudo apt install python-is-python3"
        Write-Host "The last command is necessary to make the 'python' command point to 'python3'."
        return
    }
}

# Create virtual environment with Python 3.11 (recommended for Ansible)
python -m venv ansible-env

# Activate the virtual environment (Linux path)
. ./ansible-env/bin/activate

# Install Ansible in the virtual environment
pip install ansible
# Verify Ansible installation
ansible --version
Write-Host "`nPython and Ansible environment is ready!"