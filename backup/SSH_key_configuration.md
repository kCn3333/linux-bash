## SSH key configuration for remote backups

For remote backups, it is strongly recommended to use **SSH keys** instead of passwords.  
This allows the script to run automatically (e.g., via `cron`) without manual password entry.

1. Generate SSH key
On your local machine (where the backup script runs):
```bash
ssh-keygen -t ed25519 -C "backup-key"
```
Press Enter to accept the default path (`~/.ssh/id_ed25519`) and leave the passphrase empty for fully automated usage.

2. Copy key to the remote server
```bash
ssh-copy-id user@server
```
This installs your public key on the server, enabling passwordless login.

3. Test the connection
```bash
ssh user@server
```
If you log in without being asked for a password, the setup is correct.

4. Optional: SSH config file
You can simplify remote backup usage by adding an entry to `~/.ssh/config`:

```bash
Host backupserver
    HostName server.example.com
    User user
    IdentityFile ~/.ssh/id_ed25519
```
Now you can run the script like this:

```bash
sudo ./backup.sh --remote backupserver:/path/to/backups
```
This avoids typing `user@server` each time and ensures the correct key is used.