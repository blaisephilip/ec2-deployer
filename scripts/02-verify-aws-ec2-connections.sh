#!/bin/bash

# Start time measurement
start_time=$(date +%s)

source "$(dirname "$0")/parse_config.sh"

# Set your EC2 instance ID
# Sanitize and trim values that may contain Windows CRLF or extra whitespace
INSTANCE_ID="${instance_id//$'\r'/}"            # remove CR
INSTANCE_ID="$(echo -n "$INSTANCE_ID" | xargs)" # trim whitespace

KEY_FILE="${key_file//$'\r'/}"
KEY_FILE="$(echo -n "$KEY_FILE" | xargs)"

# Validate instance ID format early to fail fast
if [[ ! $INSTANCE_ID =~ ^i-[0-9a-fA-F]+$ ]]; then
    echo "Error: Invalid instance id: '$INSTANCE_ID'"
    echo "Check config/ec2_config.yml for stray whitespace or CRLF line endings."
    exit 1
fi

# If running under WSL and the key file looks like a Windows path (C:\...), convert it
if [[ "$KEY_FILE" =~ ^[A-Za-z]:\\ ]]; then
    if command -v wslpath &>/dev/null; then
        KEY_FILE=$(wslpath -a "$KEY_FILE")
    else
        drive=$(echo "$KEY_FILE" | cut -d: -f1 | tr 'A-Z' 'a-z')
        rest="${KEY_FILE:2}"
        rest="${rest//\\//}"
        KEY_FILE="/mnt/$drive$rest"
    fi
fi

echo $KEY_FILE

# Verify key file exists
if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Key file not found: $KEY_FILE"
    exit 1
fi

# Set your EC2 instance ID (use sanitized values below)
INSTANCE_ID="$INSTANCE_ID"
KEY_FILE="$KEY_FILE"

if [ -z "$INSTANCE_ID" ] || [ -z "$KEY_FILE" ]; then
    echo "Error: INSTANCE_ID or KEY_FILE is not set in the configuration."
    exit 1
fi

echo "Testing connection to EC2 instance: $INSTANCE_ID"

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


if [ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip') ];
then
        echo "Script is running under WSL, adjust the path of private key."

        KEY_FILE=$(wslpath -a "$KEY_FILE")
        echo "Converted key file path for WSL: $KEY_FILE"
        
        WSL_UBUNTUUSER=$(bash -lc 'id -un')
        echo "Detected WSL Ubuntu user:" $WSL_UBUNTUUSER
        #KEY_TARGET_PATH="\\wsl$\Ubuntu\home\\$WSL_UBUNTUUSER\.ssh\\$(basename $KEY_FILE)"

        #sudo cp -f $KEY_FILE ~/.ssh/⁣
        #chmod 400 ~/.ssh/⁣$(basename $KEY_FILE)
        KEY_FILE="~/.ssh/⁣$(basename $KEY_FILE)"

        #KEY_TARGET_PATH="~\\.ssh\\$(basename $KEY_FILE)"
        # Copy the key file into the WSL home .ssh directory
        #sudo cp -f $KEY_FILE $KEY_TARGET_PATH
        #WSL_KEY_FILE="\\wsl$\Ubuntu\home\\$WSL_UBUNTUUSER\.ssh\\$(basename $KEY_FILE)"
        #echo "WSL Key file path: $KEY_TARGET_PATH"
        #chmod 400 $KEY_FILE
        #KEY_FILE=$KEY_TARGET_PATH
fi

# Test SSH connection
echo "Testing SSH connection..."
echo "Key file used: $KEY_FILE"
echo "SSH user: $SSH_USER"
echo "Public IP: $PUBLIC_IP"

#ssh -i $KEY_FILE $SSH_USER@$PUBLIC_IP 

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

# Calculate and display execution time
end_time=$(date +%s)
duration=$((end_time - start_time))

hours=$((duration / 3600))
minutes=$(( (duration % 3600) / 60 ))
seconds=$((duration % 60))

# Format with leading zeros
printf "Duration: %02d:%02d:%02d\n" $hours $minutes $seconds