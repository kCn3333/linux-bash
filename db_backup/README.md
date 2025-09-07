# Docker Database Backup 

A simple and reliable Docker database backup script supporting `MySQL/MariaDB`, `PostgreSQL`, `MongoDB`, and `SQLite`. Designed to safely backup live containerized databases without stopping them.

## Features

- Backups live Docker container databases without stopping them.
- Automatically checks if the required dump tool (`mysqldump`, `pg_dump`, `sqlite3`) exists inside the container.
- Supports `gzip` compression.
- Logs progress and sizes for each backup. Automatically rotates logs to prevent oversized log files.
- Cleans up old backups, keeping:
    - Last 7 daily backups
    - 1 backup from the last week
    - 1 backup from the last month

## Requirements 

- Bash shell (Linux or WSL).
- Access to containers environment variables (`MYSQL_USER`, `POSTGRES_USER`, etc.).
- User permissions to read/write backup directories.

## Usage

Clone the repository or copy the script and then make it executable:
```
chmod +x db_backup.sh
```
Run manually for testing:
```
./db_backup.sh
```

Check logs:
```
cat ~/db_backups/logs/db_backup.log
```

### Adding to Cron

To run the backup automatically:

Open the crontab for your user:
```
crontab -e
```

Add the following line, for daily at 2:20 AM:
```
20 2 * * * /home/user/path-to-dir/db_backup.sh
```

## Restoring a Backup
### MySQL/MariaDB
```
gunzip < backup.sql.gz | docker exec -i <container_name> mysql -u <user> -p<password> <database>
```
### PostgreSQL
```
export PGPASSWORD=<password>
gunzip < backup.sql.gz | docker exec -i <container_name> psql -U <user> -d <database>
unset PGPASSWORD
```
### MongoDB
```
gunzip < backup.archive.gz | docker exec -i <container_name> mongorestore --archive
```
### SQLite
```
gunzip < backup.sql.gz > db.sqlite
```

Replace the database inside the container
```
docker cp db.sqlite <container_name>:/data/db.sqlite
```

---

⚠️ Always test restores in a safe environment before restoring production databases. 
It is recommended to stop the target container before restoring a backup to avoid data corruption.



