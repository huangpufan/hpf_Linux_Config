#!/bin/bash

# Define the file paths
PROFILE_FILE="$HOME/.profile"
BACKUP_PROFILE_FILE="$HOME/.profile.bak"
BASHRC_FILE="$HOME/.bashrc"
MY_PROFILE_FILE="$HOME/hpf_Linux_Config/install-script/basic/profile/profile"

# Define the new string to look for and the string to add
SEARCH_STRING="Profile already set"
ADD_STRING="if [ -s $BASHRC_FILE ]; then\n    source $BASHRC_FILE\nfi\n# Profile already set"

# Check if the .profile file exists
if [ -f "$PROFILE_FILE" ]; then
    # Check if the string exists in the profile file
    if grep -qF "$SEARCH_STRING" "$PROFILE_FILE"; then
        # If the string exists, rename the original profile file
        mv "$PROFILE_FILE" "$BACKUP_PROFILE_FILE"
        echo "Original .profile has been renamed to .profile.bak."
    else
        echo "The marker does not exist in your .profile, proceeding to create a new one."
    fi
else
    echo "The .profile file does not exist, creating a new one."
fi

# Create a new .profile file with the new content
ln -s "$MY_PROFILE_FILE" "$PROFILE_FILE"
echo "A new .profile file has been created with the conditional .bashrc source block."
