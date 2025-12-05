#!/usr/bin/env bash
set -Eeuo pipefail

# Check for backup suffix argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <backup_suffix>"
    echo "Example: $0 20231201"
    exit 1
fi

BACKUP_SUFFIX=$1

# Define the directories for backup
CONFIG_DIR="$HOME/.config/nvim"
LOCAL_SHARE_DIR="$HOME/.local/share/nvim"
CACHE_DIR="$HOME/.cache/nvim"
STATE_DIR="$HOME/.local/state/nvim"

# Backup function
backup_directory() {
    local src_dir=$1
    local backup_dir="${src_dir}_backup_${BACKUP_SUFFIX}"

    # Check if the backup directory already exists
    if [ -d "$backup_dir" ]; then
        echo "[ERROR] Backup directory $backup_dir already exists. Aborting backup."
        exit 1
    fi

    # Check if the source directory exists and perform backup
    if [ -d "$src_dir" ]; then
        mv "$src_dir" "$backup_dir"
        echo "Backup created: $backup_dir"
    else
        echo "Source directory $src_dir does not exist, skipping backup."
    fi
}

# Perform the backups
backup_directory "$CONFIG_DIR"
backup_directory "$LOCAL_SHARE_DIR"
backup_directory "$CACHE_DIR"
backup_directory "$STATE_DIR"

echo ""
echo "Backup completed with suffix: $BACKUP_SUFFIX"
