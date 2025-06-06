# AWS CLI installation on Ubuntu target

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