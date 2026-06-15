#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BASHRC_PATH="$HOME/.bashrc"
MARKER="# Bashrc Already Set - managed by hpf_Linux_Config"

# Link bash config files to the stow-managed home/ sources.
ln -sf "$REPO_ROOT/home/.bash-env" ~/.bash-env
ln -sf "$REPO_ROOT/home/.bash-aliases" ~/.bash-aliases
ln -sf "$REPO_ROOT/home/.bash-source" ~/.bash-source

touch "$BASHRC_PATH"
if ! grep -qF "$MARKER" "$BASHRC_PATH"; then
    cat >> "$BASHRC_PATH" <<'EOF'

# Bashrc Already Set - managed by hpf_Linux_Config
if [ -f "$HOME/.bash-env" ]; then
    . "$HOME/.bash-env"
fi
if [ -f "$HOME/.bash-aliases" ]; then
    . "$HOME/.bash-aliases"
fi
if [ -f "$HOME/.bash-source" ]; then
    . "$HOME/.bash-source"
fi
# End hpf_Linux_Config bashrc block
EOF
fi

echo "Bashrc configuration completed!"
echo "Please run 'source ~/.bashrc' or restart your terminal."
