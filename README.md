# User Creation and Management Script

This script automates the process of creating a new user, setting a default password, applying disk quotas, and configuring login time restrictions. It is designed to be run on a Linux-based system (Ubuntu/Debian), and it requires superuser privileges to function correctly.

## Prerequisites

Before running the script, ensure the following:

- You have superuser (root) privileges to run the script and modify system files.
- The `quota` package is installed on your system. If not, the script will automatically install it.
- The system is using **ext4** as the filesystem for the root partition (`/`).

## Usage

```bash
./create_user.sh <username> <comment> <default_shell> <validity_days>

```

## Parameters:
<username>: The username of the new user.
<comment>: A description for the user (e.g. "Adama").
<default_shell>: The default shell for the user (e.g., /bin/bash).
<validity_days>: The number of days until the user account expires.

## Exemple
```./create_user.sh Adama "je suis Adama" /bin/bash 10```

This command will create a user adama with the comment "je suis Adama", the default shell /bin/bash, and the account will expire in 10 days.

After the execution of the script a reboot will be necessary for the os take account of all the changes made, so you are advised to ```reboot the system```


## Features

1. User Creation
Creates the user with a specified username, comment, and default shell.
Sets the expiration date of the account based on the number of days provided.
The default password is set to inf3611. The user will be required to change their password at first login.

2. Quota Management
The script assigns a 2GB disk quota (soft and hard limits) to the user.
It ensures that the quota tools (quota, quotacheck, quotaon, setquota) are installed and configured.
It enables disk quotas on the root partition by adding necessary entries to /etc/fstab.

3. Login Time Restrictions
The script restricts the user’s login hours to 8:00 AM - 6:00 PM, Monday through Friday.
The login restrictions are applied by modifying /etc/security/time.conf.


## Sample Output

Enabling quota in /etc/fstab...
Quota options already present in /etc/fstab.
Remounting root filesystem...
Initializing and enabling quotas...
quotacheck: Quota for users is enabled on mountpoint / so quotacheck might damage the file.
Please turn quotas off or use -f to force checking.
quotaon: Your kernel probably supports ext4 quota feature but you are using external quota files. Please switch your filesystem to use ext4 quota feature as external quota files on ext4 are deprecated.
quotaon: cannot find //aquota.group on /dev/vda3 [/]
quotaon: using //aquota.user on /dev/vda3 [/]: Device or resource busy
Creating user Jabana...
BAD PASSWORD: The password is shorter than 8 characters
Setting quota for Jabana...
Configuring PAM for login time restrictions...
Configuring time restrictions for user: Jabana
Time restriction rule updated in /etc/security/time.conf.
Updating PAM configuration in /etc/pam.d/sshd
PAM configuration updated.
Restarting SSH service to apply changes.
Failed to restart sshd.service: Unit sshd.service not found.
SSH service restarted.
Time-based login restriction configured successfully for user: 
User Jabana created successfully!
Password: inf3611
Quota: 2 GB
Valid for: 10 days
Login hours: 8:00 AM - 6:00 PM (Mon-Fri)
