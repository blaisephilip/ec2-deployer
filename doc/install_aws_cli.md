# AWS CLI installation

## Ubuntu

Use the following commands to install the AWS command line interface on Ubuntu:

```code
cd ~
md aws
cd aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo apt update
sudo apt install unzip

unzip awscliv2.zip
sudo ./aws/install
aws --version
```

Get access keys in the user-specific AWS workspace:  
IAM > Users > blaise > Create access key  

```code
aws configure
aws iam list-users
aws sts get-caller-identity
```

Remove the aws directory. It is not needed anymore.  

Prepare the WSL Ubuntu distibution to handle metadata of Windows file system files:  

Adjust the content of /etc/wsl.conf and restart all WSL shells for effect.  

```shell
[boot]
systemd=true

[user]
default=yourusername

[automount]
options = "metadata"
```
