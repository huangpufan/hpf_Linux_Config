#!/bin/bash

# Check for restore suffix argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <restore_suffix>"
  exit 1
fi

RESTORE_SUFFIX=$1

# Define the directories for restore
CONFIG_DIR="$HOME/.config/nvim"
LOCAL_SHARE_DIR="$HOME/.local/share/nvim"
CACHE_DIR="$HOME/.cache/nvim"
STATE_DIR="$HOME/.local/state/nvim"

# Restore function
restore_backup() {
  local target_dir=$1
  local backup_dir="${target_dir}_backup_${RESTORE_SUFFIX}"

  # Check if the current configuration directory exists
  if [ -d "$target_dir" ]; then
    echo "Configuration directory $target_dir already exists. Aborting restore."
    exit 1
  fi

  # Check if the backup directory exists and perform restore
  if [ -d "$backup_dir" ]; then
    mv "$backup_dir" "$target_dir"
    echo "Restored $target_dir from $backup_dir"
  else
    echo "Backup directory $backup_dir does not exist, skipping restore."
  fi
}

# Perform the restoration
restore_backup "$CONFIG_DIR"
restore_backup "$LOCAL_SHARE_DIR"
restore_backup "$CACHE_DIR"
restore_backup "$STATE_DIR"

echo "Restore completed with suffix $RESTORE_SUFFIX"
