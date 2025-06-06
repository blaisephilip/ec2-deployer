#!/bin/bash

source "$(dirname "$0")/parse_config.sh"

# Set your EC2 instance ID
INSTANCE_ID="$instance_id"
KEY_FILE="$key_file"

if [ -z "$INSTANCE_ID" ] || [ -z "$KEY_FILE" ]; then
    echo "Error: INSTANCE_ID or KEY_FILE is not set in the configuration."
    exit 1
fi

echo "Testing SSM connection to EC2 instance: $INSTANCE_ID"

# Check AWS CLI configuration
if ! aws sts get-caller-identity &>/dev/null; then
    echo "Error: AWS CLI not configured. Run 'aws configure' first."
    exit 1
fi

# List all security groups and their IDs
aws ec2 describe-security-groups \
    --query 'SecurityGroups[*].[GroupId,GroupName,Description]' \
    --output table
if [ $? -ne 0 ]; then
    echo "Error: Failed to list security groups. Check your AWS CLI configuration."
    exit 1
fi

aws ec2 describe-security-groups \
    --filters Name=group-name,Values=sg-06fd5f15b088a34d6 \
    --query 'SecurityGroups[*].IpPermissions[?ToPort==`22`]' \
    --output table

# Check if instance exists and is running
echo "Checking instance status..."
STATE=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[].Instances[].State.Name' \
    --output text)

if [ "$STATE" != "running" ]; then
    echo "Error: Instance is not running (current state: $STATE)"
    exit 1
fi
echo "Status of the instance $INSTANCE_ID: $STATE" 

# Get instance public IP
echo "Getting instance public IP..."
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text)

if [ -z "$PUBLIC_IP" ]; then
    echo "Error: No public IP found. Check if instance has public IP assigned."
    exit 1
fi

echo "Instance public IP: $PUBLIC_IP"

# Get the AMI ID
AMI_ID=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[].Instances[].ImageId' \
    --output text)

# Determine SSH user based on AMI
if [[ $AMI_ID == ami-*ubuntu* ]]; then
    SSH_USER="ubuntu"
elif [[ $AMI_ID == ami-*debian* ]]; then
    SSH_USER="admin"
else
    SSH_USER="ec2-user"
fi

# Test SSH connection
echo "Testing SSH connection..."
ssh -i $KEY_FILE -o ConnectTimeout=5 -o BatchMode=yes \
    -o StrictHostKeyChecking=no $SSH_USER@$PUBLIC_IP exit 2>/dev/null

if [ $? -eq 0 ]; then
    echo "SSH connection successful!"
else
    echo "SSH connection failed. Please check:"
    echo "1. Security group allows inbound SSH (port 22)"
    echo "2. Key pair ($KEY_FILE) exists and has correct permissions (chmod 400)"
    echo "3. Instance has public IP and is reachable"
    exit 1
fi