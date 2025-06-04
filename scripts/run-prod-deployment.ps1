# Activate the Python virtual environment
.\ansible-env\Scripts\activate

cd ..\ansible
echo "#################################################################"
echo "Running Ansible playbook for production deployment..."
ansible-playbook -i inventory/production.ini playbooks/deploy-docker.yml
cd ..\scripts
echo "#################################################################"

# Deactivate virtual environment
deactivate
