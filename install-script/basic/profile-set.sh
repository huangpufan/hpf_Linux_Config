#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the file paths
PROFILE_FILE="$HOME/.profile"
BACKUP_PROFILE_FILE="$HOME/.profile.bak"
MY_PROFILE_FILE="$SCRIPT_DIR/profile/profile"

# Define the marker string
SEARCH_STRING="Profile already set"

# Check if the .profile file exists and already configured
if [ -f "$PROFILE_FILE" ]; then
    if grep -qF "$SEARCH_STRING" "$PROFILE_FILE"; then
        echo ".profile is already configured, skipping."
        exit 0
    else
        # Backup existing profile
        mv "$PROFILE_FILE" "$BACKUP_PROFILE_FILE"
        echo "Original .profile has been renamed to .profile.bak."
    fi
fi

# Check if target profile exists
if [ ! -f "$MY_PROFILE_FILE" ]; then
    echo "[ERROR] Profile template not found: $MY_PROFILE_FILE"
    exit 1
fi

# Create symlink to our profile
ln -sf "$MY_PROFILE_FILE" "$PROFILE_FILE"
echo "A new .profile file has been linked successfully."
