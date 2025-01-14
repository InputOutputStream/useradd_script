#!/bin/bash

USERNAME=$1
COMMENT=$2
SHELL=$3
EXP_DAYS=$4
PASS="inf3611"
QUOTA=$((2*1024*1024)) # 2GB in KB

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Check if all arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <username> <comment> <default_shell> <validity_days>"
    exit 1
fi

# Install quota tools if not present
if ! command -v setquota &>/dev/null; then
    echo "Installing quota tools..."
    sudo apt update && sudo apt install quota -y
fi

# Enable quotas in /etc/fstab
echo "Enabling quota in /etc/fstab..."
FSTAB_ENTRY=$(grep "/ " /etc/fstab)
if [[ $FSTAB_ENTRY != *"usrquota"* ]]; then
    sudo sed -i 's|\(/.*ext4.*\)errors=remount-ro|\1errors=remount-ro,usrquota,grpquota|' /etc/fstab
    echo "Quota options added to /etc/fstab."
else
    echo "Quota options already present in /etc/fstab."
fi

# Remount the root filesystem
echo "Remounting root filesystem..."
sudo mount -o remount /

# Create quota files and enable quotas
echo "Initializing and enabling quotas..."
sudo quotacheck -cum /
sudo quotaon -v /

# Create the user
echo "Creating user $USERNAME..."
sudo useradd -m -c "$COMMENT" -s "$SHELL" -e $(date -d "+$EXP_DAYS days" +%Y-%m-%d) "$USERNAME"

# Set the default password
echo "$USERNAME:$PASS" | sudo chpasswd

# Force password change at first login
sudo chage -d 0 "$USERNAME"

# Assign quota to the user
echo "Setting quota for $USERNAME..."
sudo setquota -u "$USERNAME" $QUOTA $QUOTA 0 0 /

# Configure login time restrictions (8:00 - 18:00)
echo "Configuring login time restrictions..."
LOGIN_TIME_RULE="adama;*;!Wk0800-1800" # Restricts logins outside Mon-Fri 8:00-18:00
if ! grep -q "$LOGIN_TIME_RULE" /etc/security/time.conf; then
    echo "$LOGIN_TIME_RULE" | sudo tee -a /etc/security/time.conf
fi

# Final message
echo "User $USERNAME created successfully!"
echo "Password: $PASS"
echo "Quota: 2 GB"
echo "Valid for: $EXP_DAYS days"
echo "Login hours: 8:00 - 18:00"
