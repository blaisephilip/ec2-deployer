# ec2-deployer

Docker-based deployment of Node.js/React applications to AWS EC2 using Ansible.

## Prerequisites

- Debian-based OS
- AWS EC2 instance running Amazon Linux 2
- Node.js/React application in a Git repository

## Setup

### Install required tools:

**Ansible**

```bash
cd scripts
./01-setup-environment.sh
```

The script shall prompt you to install missing APT packages. If all packages are present, it will create a virtual environment to run Ansible.  

**AWS CLI**  
Follow the instructions in doc/install_aws_cli.md.  

### Test the connection to the EC2 instance


Create a file called ec2_config.yml in the config folder in the root of this repository. Adapt this as file content:  

```bash
---
aws_region: eu-central-1
instance_id: i-00262d6502547ef43
key_file: ~/.ssh/ansible-docker-deployer.pem
```

The region is your AWS EC2 instance's region.  
The instance ID is visible in AWS Console.  
The key file is automatically downloaded when it is created in AWS. Place the file to ~/.ssh/ and adjust its access rights. (chmod 400) Change the file name as necessary.  

Execute the following:  

```bash
cd scripts
./02-verify-aws-ec2-connections.sh
```

The connection test shall run successful.

### Extend and update the inventory configuration

Edit `ansible/inventory/production.ini` with your EC2 details: The ansible_ssh_private_key_file and the ansible_host IP value shall be adjusted.  
- Use the EC2 instance's public IPv4 value.  
- Adjust the SSH key name in the production.ini file as necessary.

### Verify the server(s) added in the ansible inventory

```bash
cd scripts
./03-verify-ansible-inventory.sh
```

### Test a server connection via Ansible playbook

Make sure that the EC2 instance is used with an IAM role that has a policy with such actions:  

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": "*"
        }
    ]
}
```

If the policy above is attached to the role, execute the following commands:  

```bash
cd scripts
./04-run-playbook-test.sh
```

The production.ini inventory config is used in this playbook to test if Ansible can interact with the EC2 instance. Detailed EC2 information is retrieved by Ansible in this step. If package-related access problems occur, consider adding more packages to the test-connection.yml file in the pre_tasks section.

### Edit the application-specfic configuration

- Update `ansible/group_vars/all.yml` with your settings

## Deploy

Deployment variants:
1. Local build, local image, direct deployment to EC2.
2. Local build, local image, image push to Github, deployment to EC2 from Github controlled by local Ansible playbook.
3. Local build, local image, image push to Github, deployment to EC2 from Github controlled by Github Actions.
4. Remote build via Github Actions, deployment to EC2 by local Ansible.
5. Remote build via Github Actions, deployment to EC2 by Github Actions.
6. Cloning and build on the EC2 instance.

Currently implemented variant: 1.

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
* For Amazon Linux 2 AMI: use ec2-user
* For Ubuntu AMI: use ubuntu
* For RHEL AMI: use ec2-user

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
