#!/bin/bash

# ------------------------------
# Color and icon functions
# ------------------------------
GREEN="\e[38;2;166;227;161m"   # pastel green
YELLOW="\e[38;2;249;226;175m"  # light cream-yellow
RED="\e[38;2;243;139;168m"     # raspberry/red
BLUE="\e[38;2;137;180;250m"    # blue
MAGENTA="\e[38;2;245;194;231m" # pink
CYAN="\e[38;2;137;220;235m"    # cyan
WHITE="\e[38;2;205;214;244m"   # light gray/white
RESET="\e[0m"
NC='\033[0m' # no color

ICON_INFO="ℹ️ "
ICON_OK="✅"
ICON_WARN="⚠️"
ICON_ERROR="❌"

MAX_BACKUPS=2
SECONDS=0  # start counting time

# ------------------------------
# File with list of directories to backup
# ------------------------------
DIRECTORY_LIST="directory_list.txt"

if [ ! -f "$DIRECTORY_LIST" ]; then
    echo -e "${RED}${ICON_ERROR} File $DIRECTORY_LIST does not exist!${NC}"
    exit 1
fi

# ------------------------------
# Parse arguments (local or remote mode)
# ------------------------------
IS_REMOTE=false
if [ "$1" == "--remote" ]; then
    if [ -z "$2" ]; then
        echo -e "${RED}${ICON_ERROR} No remote target specified!${NC}"
        echo -e "${YELLOW}${ICON_INFO} Usage: sudo $0 --remote user@server:/path/to/backups${NC}"
        exit 1
    fi
    REMOTE_TARGET="$2"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$REMOTE_TARGET/backup_$TIMESTAMP"
    IS_REMOTE=true
else
    if [ -z "$1" ]; then
        echo -e "${RED}${ICON_ERROR} No target disk specified!${NC}"
        echo -e "${YELLOW}${ICON_INFO} Usage: sudo $0 /path/to/target_disk${NC}"
        exit 1
    fi
    TARGET_DISK="$1"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$TARGET_DISK/backup_$TIMESTAMP"
fi

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}${ICON_ERROR} Run as root (sudo)!${NC}"
    exit 1
fi

# ------------------------------
# Create backup folder with timestamp
# ------------------------------
if [ "$IS_REMOTE" = true ]; then
    ssh "${REMOTE_TARGET%%:*}" "mkdir -p \"$BACKUP_DIR\""
else
    mkdir -p "$BACKUP_DIR"
fi
echo -e "${CYAN}${ICON_INFO} Creating backup folder: $BACKUP_DIR${NC}"

# ------------------------------
# Read directories from file and copy
# ------------------------------
while IFS= read -r DIR; do
    [[ -z "$DIR" || "$DIR" == \#* ]] && continue

    if [ -d "$DIR" ]; then
        echo -e "${BLUE}${ICON_INFO} Copying $DIR...${NC}"
        RSYNC_LOG="backup_rsync.log"
        if [ "$IS_REMOTE" = true ]; then
            rsync -aAXv --progress --exclude-from=exclude.txt "$DIR/" "$BACKUP_DIR/" 2>&1 | tee -a "$RSYNC_LOG"
        else
            rsync -aAXv --progress --exclude-from=exclude.txt "$DIR/" "$BACKUP_DIR/" 2>&1 | tee -a "$BACKUP_DIR/$RSYNC_LOG"
        fi
        echo -e "${GREEN}${ICON_OK} Copied $DIR${NC}"
    else
        echo -e "${YELLOW}${ICON_WARN} Directory $DIR does not exist, skipping.${NC}"
    fi
done < "$DIRECTORY_LIST"

# ------------------------------
# Backup rotation – keep only MAX_BACKUPS latest
# ------------------------------
if [ "$IS_REMOTE" = true ]; then
    BACKUP_FOLDERS=($(ssh "${REMOTE_TARGET%%:*}" "ls -1d ${REMOTE_TARGET#*:}/backup_* 2>/dev/null | sort -V"))
else
    BACKUP_FOLDERS=($(ls -1d "$TARGET_DISK"/backup_* 2>/dev/null | sort -V))
fi
NUM_BACKUPS=${#BACKUP_FOLDERS[@]}

if [ "$NUM_BACKUPS" -gt "$MAX_BACKUPS" ]; then
    NUM_TO_DELETE=$((NUM_BACKUPS - MAX_BACKUPS))
    echo -e "${YELLOW}${ICON_WARN} Deleting $NUM_TO_DELETE oldest backups...${NC}"
    for ((i=0; i<NUM_TO_DELETE; i++)); do
        if [ "$IS_REMOTE" = true ]; then
            ssh "${REMOTE_TARGET%%:*}" "rm -rf \"${BACKUP_FOLDERS[i]}\""
        else
            rm -rf "${BACKUP_FOLDERS[i]}"
        fi
        echo -e "${GREEN}${ICON_OK} Deleted: ${BACKUP_FOLDERS[i]}${NC}"
    done
fi

# ------------------------------
# Calculate duration
# ------------------------------
DURATION=$SECONDS
HOURS=$((DURATION/3600))
MINUTES=$(((DURATION%3600)/60))
SECONDS_LEFT=$((DURATION%60))

echo -e "${CYAN}${ICON_INFO} Backup completed in ${HOURS}h ${MINUTES}m ${SECONDS_LEFT}s. Target folder: $BACKUP_DIR${NC}"
