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
Initializing and enabling quotas...
Creating user adama...
Setting quota for adama...
Configuring login time restrictions...
User jdoe created successfully!
Password: inf3611
Quota: 2 GB
Valid for: 30 days
Login hours: 8:00 - 18:00

