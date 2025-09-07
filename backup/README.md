# Backup Script

A simple **Bash backup script** for Linux that automatically creates timestamped backups of selected directories onto a chosen **local disk** (e.g. external USB drive) or a **remote server via SSH**.  

It uses `rsync` for efficient incremental copying, logs all operations, and manages automatic backup rotation.

---

## Features
- Backup directories listed in `directory_list.txt`.  
- Exclude files/directories defined in `exclude.txt` (can be empty).  
- Supports **two modes**:  
  - **Local backup** → to a mounted disk path.  
  - **Remote backup** → to a server via SSH (`--remote user@server:/path`).  
- Timestamped backup directories: `backup_YYYYMMDD_HHMMSS`.  
- Keeps only the last `MAX_BACKUPS` backups.
- `Incremental backup` so only new and changed files are copied, unchanged files are skipped.    
- Logs `rsync` output into each backup folder.  

## Required files

The script expects two files in the same directory:

1. **`directory_list.txt`**  
   Contains the list of directories to back up, one per line.  
   Lines starting with `#` are ignored.  
2. **`exclude.txt`** 
Defines which files/directories should be excluded from backup.

3. Installed **`rsync`**  and **`ssh`**. 
4. Root privileges (**`sudo`**).

## Rsync options explained

The script uses the following rsync options:

**-a** (archive mode) → preserves symbolic links, permissions, modification times, group, and ownership.

**-A** (ACLs) → preserves Access Control Lists.

**-X** (xattrs) → preserves extended attributes.

**-v** (verbose) → shows detailed progress in the output.

**--progress** → displays file-level progress during copy.

**--exclude-from=exclude.txt** → reads a list of exclusion patterns from the file `exclude.txt`.

Together, these options ensure that backups are as close as possible to the original system state, including permissions and metadata.

## Usage

### Local backup
Run the script with root privileges and specify the target disk mount point as argument:
```
sudo ./backup.sh /usb_disk
```

Backups will be created under:
```
/usb_disk/backup_YYYYMMDD_HHMMSS
```

### Remote backup

Run the script with --remote and provide a user, server, and path:
```
sudo ./backup.sh --remote user@server:/path/to/backups
```

Backups will be created under:
```
/path/to/backups/backup_YYYYMMDD_HHMMSS
```

on the remote server.
It is recommended to configure **`SSH keys`** for passwordless login.

## Backup rotation
By default, the script keeps only the 2 most recent backups.
Older backups are automatically deleted.
This can be adjusted by editing the `MAX_BACKUPS` variable inside the script. 

Each `backup_YYYYMMDD_HHMMSS` folder contains a full copy of the selected directories, but because rsync works incrementally, only changed files are actually copied during each run.
This means backups are fast and efficient, while still letting you restore any version.

## Restore from backup
To restore a specific file or directory, simply copy it back using `rsync` or `cp`.

### Restore a single file (local backup):
```
rsync -av /media/username/usb_disk/backup_20250904_124500/home/user/Documents/report.pdf /home/user/Documents/
```

### Restore from remote backup:
```
rsync -av user@server:/path/to/backups/backup_20250904_124500/home/user/Documents/report.pdf /home/user/Documents/
```

## ⚠️ Notes

- Always ensure the target disk is mounted before running the script.
- Running without sudo will result in an error (permissions are needed for system directories).
- You must provide both `directory_list.txt` and `exclude.txt` (could be empty) in the script’s directory.
- For remote backups, configure **`SSH keys`** for secure, passwordless automation.
