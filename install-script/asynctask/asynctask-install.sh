#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/install/asynctasks.vim"

# Clone asynctasks.vim if not exists
if [ ! -d "$INSTALL_DIR" ]; then
    git clone --depth 1 https://github.com/skywind3000/asynctasks.vim "$INSTALL_DIR"
fi

# Create bin directory if not exists
mkdir -p "$HOME/bin"

# Create symlinks
if [ ! -L "$HOME/bin/asynctask" ] && [ ! -e "$HOME/bin/asynctask" ]; then
    ln -s "$INSTALL_DIR/bin/asynctask" "$HOME/bin/asynctask"
fi

# Link tasks.ini to nvim config
mkdir -p "$HOME/.config/nvim"
if [ ! -L "$HOME/.config/nvim/tasks.ini" ] && [ ! -e "$HOME/.config/nvim/tasks.ini" ]; then
    ln -s "$SCRIPT_DIR/tasks.ini" "$HOME/.config/nvim/tasks.ini"
fi

echo "asynctask installed successfully!"
