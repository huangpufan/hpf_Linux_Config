#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if the Bashrc Already Set string exists in the .bashrc file
if grep -q "Bashrc Already Set" ~/.bashrc; then
    echo "Bashrc already set. Skipping script execution."
    exit 0
fi

# Create symlinks for bash config files
ln -sf "$SCRIPT_DIR/bash/env" ~/.bash-env
ln -sf "$SCRIPT_DIR/bash/aliases" ~/.bash-aliases
ln -sf "$SCRIPT_DIR/bash/source" ~/.bash-source

# Add the bashrc-append to the end of ~/.bashrc
cat "$SCRIPT_DIR/bash/bashrcappend" >> ~/.bashrc

echo "Bashrc configuration completed!"
echo "Please run 'source ~/.bashrc' or restart your terminal."
