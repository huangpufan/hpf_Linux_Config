#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check if the Bashrc Already Set string exists in the .bashrc file
if grep -q "Bashrc Already Set" ~/.bashrc; then
    echo "Bashrc already set. Skipping script execution."
    exit 0
fi

# Create symlinks for bash config files — target the stow-managed home/ sources
ln -sf "$REPO_ROOT/home/.bash-env" ~/.bash-env
ln -sf "$REPO_ROOT/home/.bash-aliases" ~/.bash-aliases
ln -sf "$REPO_ROOT/home/.bash-source" ~/.bash-source

# Add the bashrc-append to the end of ~/.bashrc
cat "$SCRIPT_DIR/bash/bashrcappend" >> ~/.bashrc

echo "Bashrc configuration completed!"
echo "Please run 'source ~/.bashrc' or restart your terminal."
