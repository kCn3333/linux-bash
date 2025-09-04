#!/bin/bash

# Docker Database Backup Script
# Supports: MySQL/MariaDB, SQLite, PostgreSQL, MongoDB
# Version: safe for cron, ignores missing containers

# ------------------------
# CONFIG
# ------------------------
CURRENT_USER=$(whoami)
BACKUPDIR="/home/$CURRENT_USER/db_backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
LOGFILE="$BACKUPDIR/logs/db_backup.log"
MAXLOGSIZE=$((1024*1024))  # 1 MB max log size
DB_COUNT=0
SECONDS=0

mkdir -p "$BACKUPDIR/logs"

# ------------------------
# COLORS & ICONS
# ------------------------
GREEN="\e[38;2;166;227;161m" 
YELLOW="\e[38;2;249;226;175m"
RED="\e[38;2;243;139;168m" 
RESET="\e[0m"

ICON_START="🚀"
ICON_DONE="✅"
ICON_ERROR="❌"

# ------------------------
# LOG ROTATION
# ------------------------
if [ -f "$LOGFILE" ] && [ $(stat -c%s "$LOGFILE") -ge "$MAXLOGSIZE" ]; then
    for n in 5 4 3 2 1; do
        if [ -f "$BACKUPDIR/logs/db_backup.log.$n" ]; then
            mv "$BACKUPDIR/logs/db_backup.log.$n" "$BACKUPDIR/logs/db_backup.log.$((n+1))"
        fi
    done
    mv "$LOGFILE" "$BACKUPDIR/logs/db_backup.log.1"
    touch "$LOGFILE"
fi

# Redirect all stdout/stderr to log file + screen
exec > >(tee >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOGFILE")) 2>&1

# Error handler
trap 'echo -e "'$RED'[$TIMESTAMP] $ICON_ERROR Error on line $LINENO'$RESET'"' ERR

echo -e "[$TIMESTAMP] ${GREEN}$ICON_START Backup started...$RESET"

# ------------------------
# MongoDB Backup
# ------------------------
while read -r i; do
    [ -z "$i" ] && continue
    DB_COUNT=$((DB_COUNT+1))

    MONGO_DB=$(docker exec "$i" env | grep MONGO_INITDB_DATABASE | cut -d"=" -f2 || true)
    MONGO_USER=$(docker exec "$i" env | grep MONGO_INITDB_ROOT_USERNAME | cut -d"=" -f2)
    MONGO_PASS=$(docker exec "$i" env | grep MONGO_INITDB_ROOT_PASSWORD | cut -d"=" -f2)
    [ -z "$MONGO_DB" ] && MONGO_DB="admin"

    FILE="$BACKUPDIR/$i-mongodb-$MONGO_DB-$TIMESTAMP.archive.gz"

    docker exec "$i" mongodump \
        --username "$MONGO_USER" \
        --password "$MONGO_PASS" \
        --authenticationDatabase admin \
        --db "$MONGO_DB" \
        --archive | gzip > "$FILE"

    echo "[$TIMESTAMP] $FILE — done, size: $(du -h "$FILE" | awk '{print $1}')"
done < <(docker ps --format '{{.Names}}:{{.Image}}' | grep -E 'mongo' | cut -d":" -f1 || true)

# ------------------------
# MySQL/MariaDB Backup
# ------------------------
while read -r i; do
    [ -z "$i" ] && continue
    DB_COUNT=$((DB_COUNT+1))

    MYSQL_USER=$(docker exec "$i" env | grep MYSQL_USER | cut -d"=" -f2)
    MYSQL_DB=$(docker exec "$i" env | grep MYSQL_DATABASE | cut -d"=" -f2)
    MYSQL_PWD=$(docker exec "$i" env | grep MYSQL_PASSWORD | cut -d"=" -f2)

    FILE="$BACKUPDIR/$i-mysql-$MYSQL_DB-$TIMESTAMP.sql.gz"

    docker exec -e MYSQL_PWD="$MYSQL_PWD" "$i" mysqldump -u "$MYSQL_USER" "$MYSQL_DB" | gzip > "$FILE"
    echo "[$TIMESTAMP] $FILE — done, size: $(du -h "$FILE" | awk '{print $1}')"
done < <(docker ps --format '{{.Names}}:{{.Image}}' | grep -E 'mariadb|mysql' | cut -d":" -f1)

# ------------------------
# PostgreSQL Backup
# ------------------------
while read -r i; do
    [ -z "$i" ] && continue
    DB_COUNT=$((DB_COUNT+1))

    PG_USER=$(docker exec "$i" env | grep POSTGRES_USER | cut -d"=" -f2)
    PG_DB=$(docker exec "$i" env | grep POSTGRES_DB | cut -d"=" -f2)
    PG_PASS=$(docker exec "$i" env | grep POSTGRES_PASSWORD | cut -d"=" -f2)

    export PGPASSWORD="$PG_PASS"

    FILE="$BACKUPDIR/$i-postgresql-$PG_DB-$TIMESTAMP.sql.gz"

    docker exec "$i" pg_dump -U "$PG_USER" "$PG_DB" | gzip > "$FILE"
    unset PGPASSWORD
    echo "[$TIMESTAMP] $FILE — done, size: $(du -h "$FILE" | awk '{print $1}')"
done < <(docker ps --format '{{.Names}}:{{.Image}}' | grep 'postgres' | cut -d":" -f1)

# ------------------------
# Vaultwarden SQLite Backup
# ------------------------
while read -r i; do
    [ -z "$i" ] && continue
    DB_COUNT=$((DB_COUNT+1))

    SQLITE_PATH=$(docker exec "$i" bash -c 'echo data/db.sqlite3 2>/dev/null')
    FILE="$BACKUPDIR/$i-sqlite-$TIMESTAMP.sql.gz"

    docker exec "$i" sqlite3 "$SQLITE_PATH" .dump | gzip > "$FILE"
    echo "[$TIMESTAMP] $FILE — done, size: $(du -h "$FILE" | awk '{print $1}')"
done < <(docker ps --format '{{.Names}}:{{.Image}}' | grep -E 'vaultwarden' | cut -d":" -f1)

# ------------------------
# Nginx Proxy Manager SQLite Backup
# ------------------------
while read -r i; do
    [ -z "$i" ] && continue
    DB_COUNT=$((DB_COUNT+1))

    SQLITE_PATH="/data/database.sqlite"
    FILE="$BACKUPDIR/$i-sqlite-$TIMESTAMP.sql.gz"

    docker exec "$i" sqlite3 "$SQLITE_PATH" .dump | gzip > "$FILE"
    echo "[$TIMESTAMP] $FILE — done, size: $(du -h "$FILE" | awk '{print $1}')"
done < <(docker ps --format '{{.Names}}:{{.Image}}' | grep -E 'nginx' | cut -d":" -f1)


# ------------------------
# Cleanup
# ------------------------
for prefix in $(ls "$BACKUPDIR" | cut -d"-" -f1-2 | sort -u); do
    ls -1t "$BACKUPDIR/$prefix-"*.sql.gz "$BACKUPDIR/$prefix-"*.archive.gz 2>/dev/null | tail -n +8 \
        | xargs -r rm -v 2>&1 | while read -r line; do echo -e "${YELLOW} $line${RESET}"; done
    find "$BACKUPDIR" \( -name "$prefix-*.sql.gz" -o -name "$prefix-*.archive.gz" \) -mtime +7 -mtime -14 | sort | head -n -1 \
        | xargs -r rm -v 2>&1 | while read -r line; do echo -e "${YELLOW} $line${RESET}"; done
    find "$BACKUPDIR" \( -name "$prefix-*.sql.gz" -o -name "$prefix-*.archive.gz" \) -mtime +30 -mtime -60 | sort | head -n -1 \
        | xargs -r rm -v 2>&1 | while read -r line; do echo -e "${YELLOW} $line${RESET}"; done
done


# ------------------------
# Finish
# ------------------------
DURATION=$SECONDS
echo -e "[$TIMESTAMP] ${GREEN}$ICON_DONE Backup completed in ${DURATION}s, $DB_COUNT database(s) dumped to $BACKUPDIR$RESET"
