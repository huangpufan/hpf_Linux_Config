#!/bin/bash

# Define the file paths
PROFILE_FILE="$HOME/.profile"
BASHRC_FILE="$HOME/.bashrc"

# Define the string to look for and the string to add
SEARCH_STRING="source ~/.bashrc"
ADD_STRING="if [ -s $BASHRC_FILE ]; then\n    source $BASHRC_FILE;\nfi"

# Check if the line exists in the profile file
if ! grep -qF "$SEARCH_STRING" "$PROFILE_FILE"; then
  # If the line doesn't exist, append the conditional source block
  echo -e "$ADD_STRING" >> "$PROFILE_FILE"
  echo "The .bashrc source block was added to your .profile."
else
  echo "Your .profile already sources .bashrc."
fi
