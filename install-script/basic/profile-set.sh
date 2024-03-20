#!/bin/bash

# Define the file paths
PROFILE_FILE="$HOME/.profile"
BASHRC_FILE="$HOME/.bashrc"

# Define the new string to look for and the string to add
SEARCH_STRING="Profile already set"
ADD_STRING="if [ -s $BASHRC_FILE ]; then\n    source $BASHRC_FILE\nfi\n# Profile already set"

# Check if the string exists in the profile file
if ! grep -qF "$SEARCH_STRING" "$PROFILE_FILE"; then
  # If the string doesn't exist, append the conditional source block and the marker
  echo -e "$ADD_STRING" >> "$PROFILE_FILE"
  echo "The conditional .bashrc source block and marker were added to your .profile."
else
  echo "Your .profile already has the marker (and presumably sources .bashrc)."
fi
