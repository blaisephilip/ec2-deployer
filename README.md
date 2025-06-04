# ec2-deployer

Docker-based deployment of Node.js/React applications to AWS EC2 using Ansible.

## Prerequisites

- Ansible installed on your local machine
- AWS EC2 instance running Amazon Linux 2
- SSH access to EC2 instance
- Node.js/React application in a Git repository

## Setup

1. Install Required Tools:

```bash
pip install ansible docker
```

2. Update Configuration:

- Edit `ansible/inventory/production.ini` with your EC2 details
- Update `ansible/group_vars/all.yml` with your settings

## Deploy

Run the deployment:

```bash
cd ansible
ansible-playbook -i inventory/production.ini playbooks/deploy-docker.yml
```

## Security Notes

- Ensure EC2 security group allows inbound traffic on port 80
- Keep SSH key secure
- Use appropriate IAM roles for EC2
- Consider implementing Docker content trust
- Use specific versions instead of 'latest' tag in production

## Benefits of Docker Deployment

- Consistent environments across development and production
- Isolated application runtime
- Easy scaling and orchestration
- Simple rollbacks using container versioning
- Improved security through containerization

### Detailed configuration

production.ini  
ansible_host: Replace with your EC2 instance's public IP or DNS  
Get your EC2 instance's public IP from AWS Console
Navigate to EC2 → Instances → Select your instance
Copy the "Public IPv4 address" or "Public IPv4 DNS"


ansible_user: The SSH user for EC2 instance  
For Amazon Linux 2 AMI: use ec2-user
For Ubuntu AMI: use ubuntu
For RHEL AMI: use ec2-user

ansible_ssh_private_key_file: Path to your .pem key file  
Use the full path to your .pem file
Use forward slashes (/) even on Windows
Common location: C:/Users/YourUsername/.ssh/your-key.pem
Example:  

```code
[webservers]  
ec2-instance ansible_host=54.234.56.78 ansible_user=ec2-user ansible_ssh_private_key_file=C:/Users/john/.ssh/my-ec2-key.pem  
```

Important Security Notes:  
Ensure your .pem file has correct permissions (chmod 400 on Linux/Mac)  
Never commit the .pem file to version control  
Consider using Ansible Vault for sensitive information  
Make sure your EC2 security group allows inbound SSH (port 22)  

To create a .pem key file for EC2 access, follow these steps:

1. Using AWS Console
Go to AWS Console
Navigate to EC2 Dashboard
Click on "Key Pairs" in the left sidebar under "Network & Security"
Click "Create Key Pair"
Fill in the details:
Name: myapp-key (use a descriptive name)
Key pair type: RSA
Private key file format: .pem
Tags: Add if needed
Click "Create key pair"
The .pem file will automatically download
2. Save the Key File
For Windows:

Move the downloaded .pem file to a secure location:

```bash
# Create .ssh directory if it doesn't exist
mkdir -p "$env:USERPROFILE\.ssh"
# Move the key file
Move-Item -Path "$env:USERPROFILE\Downloads\myapp-key.pem" -Destination "$env:USERPROFILE\.ssh\myapp-key.pem"
```

3. Set Proper Permissions

For Windows PowerShell:

```bash
# Restrict access to your user account
icacls "$env:USERPROFILE\.ssh\myapp-key.pem" /inheritance:r /grant:r "$($env:USERNAME):(R)"
```

4. Update Ansible Inventory
Update your inventory file with the new key path:

```bash
[webservers]
ec2-instance ansible_host=your-ec2-ip ansible_user=ec2-user ansible_ssh_private_key_file=C:/Users/YourUsername/.ssh/myapp-key.pem
```

Security Best Practices
Never share or commit your .pem file
Store the key in a secure location
Backup the key file safely
Use different keys for different environments
Rotate keys periodically
Testing the Connection
Test SSH access:  

```bash
ssh -i C:/Users/YourUsername/.ssh/myapp-key.pem ec2-user@your-ec2-ip
```

Test Ansible connection:

```bash
ansible -i inventory/production.ini webservers -m ping
```

If you lose the .pem file, you'll need to:
Create a new key pair
Update the EC2 instance with the new key
Update your Ansible inventory file
