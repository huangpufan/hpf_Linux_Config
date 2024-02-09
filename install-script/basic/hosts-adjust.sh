#!/bin/bash

# Used for curl install prepare.

# Check if the entry for raw.githubusercontent.com already exists
if ! grep -q "raw.githubusercontent.com" /etc/hosts; then
  # Add a new entry at the end of the file
  echo "185.199.108.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts > /dev/null
  echo "Added the entry for raw.githubusercontent.com to the /etc/hosts file."
else
  echo "The entry for raw.githubusercontent.com already exists in the /etc/hosts file."
fi
