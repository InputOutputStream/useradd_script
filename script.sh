#!/bin/bash

USERNAME=$1
COMMENT=$2
SHELL=$3
EXP_DAYS=$4
PASS="inf3611"
QUOTA=$((2*1024*1024)) # 2GB in KB



# Function to modify /etc/security/time.conf
configure_time_restriction() {
    local username="$1"
    local start_time="$2"
    local end_time="$3"

    echo "Configuring time restrictions for user: $username"
    
    # Add or update the time restriction rule in /etc/security/time.conf
    rule="sshd;*;$username;Al${start_time}-${end_time}"
    if grep -q "^sshd;.*;$username;" /etc/security/time.conf; then
        # Update existing rule
        sed -i "s/^sshd;.*;$username;.*/$rule/" /etc/security/time.conf
    else
        # Add new rule
        echo "$rule" >> /etc/security/time.conf
    fi

    echo "Time restriction rule updated in /etc/security/time.conf."
}

# Function to update PAM configuration for SSH
configure_pam_sshd() {
    local pam_config="/etc/pam.d/sshd"

    echo "Updating PAM configuration in $pam_config"
    
    # Check if the PAM rule is already present
    if ! grep -q "^account required pam_exec.so" "$pam_config"; then
        echo "account required pam_exec.so /usr/bin/test -r /etc/security/time.conf" >> "$pam_config"
    fi

    echo "PAM configuration updated."
}

# Function to restart SSH service
restart_ssh_service() {
    echo "Restarting SSH service to apply changes."
    systemctl restart sshd
    echo "SSH service restarted."
}


# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with privileges."
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

# Configure login time restrictions via PAM
echo "Configuring PAM for login time restrictions..."
start_time=0800
end_time=1800 # Restricts logins outside Mon-Fri 8:00-18:00


configure_time_restriction "$USERNAME" "$start_time" "$end_time"
configure_pam_sshd
restart_ssh_service

echo "Time-based login restriction configured successfully for user: $username"


# Final message
echo "User $USERNAME created successfully!"
echo "Password: $PASS"
echo "Quota: 2 GB"
echo "Valid for: $EXP_DAYS days"
echo "Login hours: 8:00 AM - 6:00 PM (Mon-Fri)"