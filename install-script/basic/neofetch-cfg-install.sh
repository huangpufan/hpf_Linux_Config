#!/bin/bash

# Define the file paths
NEOFETCH_CONFIG="$HOME/.config/neofetch/config.conf"
NEW_PRINT_INFO="./neofetch/conf"

# Check if the new print_info configuration file exists
if [ ! -f "$NEW_PRINT_INFO" ]; then
    echo "Error: The new print_info configuration file '$NEW_PRINT_INFO' does not exist."
    exit 1
fi

# Check if the Neofetch configuration file exists
if [ ! -f "$NEOFETCH_CONFIG" ]; then
    echo "Error: The Neofetch configuration file '$NEOFETCH_CONFIG' does not exist."
    exit 1
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
' "$NEOFETCH_CONFIG" > temp_config.conf

# Check if the awk command succeeded
if [ $? -eq 0 ]; then
    # Move the temporary file into place
    mv temp_config.conf "$NEOFETCH_CONFIG"
    echo "Neofetch configuration file has been updated."
else
    echo "Error occurred while updating the Neofetch configuration file."
fi
