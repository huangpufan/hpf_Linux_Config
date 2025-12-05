#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set tmux configuration
rm -f ~/.tmux.conf
ln -sf "$SCRIPT_DIR/tmux.conf" ~/.tmux.conf

# Set tmux completion
if [ -f "$SCRIPT_DIR/tmux-completion" ]; then
    sudo cp "$SCRIPT_DIR/tmux-completion" /etc/bash_completion.d/tmux-completion
    echo "tmux completion installed."
fi

# Install TPM (Tmux Plugin Manager) if not exists
if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth=1
fi

echo "tmux configuration installed successfully!"
echo "Press prefix + I in tmux to install plugins."
