#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the file paths
NEOFETCH_CONFIG="$HOME/.config/neofetch/config.conf"
NEW_PRINT_INFO="$SCRIPT_DIR/conf"

# Check if the new print_info configuration file exists
if [ ! -f "$NEW_PRINT_INFO" ]; then
    echo "[ERROR] The new print_info configuration file '$NEW_PRINT_INFO' does not exist."
    exit 1
fi

# Create neofetch config directory if needed
mkdir -p "$(dirname "$NEOFETCH_CONFIG")"

# Run neofetch once to generate default config if it doesn't exist
if [ ! -f "$NEOFETCH_CONFIG" ]; then
    if command -v neofetch >/dev/null 2>&1; then
        neofetch --config none --print_info 2>/dev/null || true
        # If still doesn't exist, copy a default or skip
        if [ ! -f "$NEOFETCH_CONFIG" ]; then
            echo "[WARN] Could not generate neofetch config. Skipping configuration."
            exit 0
        fi
    else
        echo "[WARN] neofetch is not installed. Skipping configuration."
        exit 0
    fi
fi

# Read the new print_info content
NEW_CONTENT=$(cat "$NEW_PRINT_INFO")

# Use awk to replace the entire print_info() function in the configuration file
awk -v replacement="$NEW_CONTENT" '
    /print_info\(\) \{/ {
        print replacement
        found = 1
        next
    }
    found && /^}/ {
        found = 0
        next
    }
    !found
' "$NEOFETCH_CONFIG" > "$NEOFETCH_CONFIG.tmp"

# Check if the awk command succeeded and file is not empty
if [ -s "$NEOFETCH_CONFIG.tmp" ]; then
    mv "$NEOFETCH_CONFIG.tmp" "$NEOFETCH_CONFIG"
    echo "Neofetch configuration file has been updated."
else
    rm -f "$NEOFETCH_CONFIG.tmp"
    echo "[WARN] Failed to update neofetch configuration."
fi
