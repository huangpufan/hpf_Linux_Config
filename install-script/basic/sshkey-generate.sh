#!/usr/bin/env bash
set -Eeuo pipefail

GIT_EMAIL="59730801@qq.com"
GIT_NAME="huangpufan"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

# Check if SSH key already exists
if [ -f "$SSH_KEY_PATH.pub" ]; then
    echo "SSH key already exists at $SSH_KEY_PATH.pub"
else
    echo "Generating new SSH key..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -q -N ""
    echo "SSH key generated successfully!"
fi

# Configure Git user name and email
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo ""
echo "Your SSH public key:"
cat "$SSH_KEY_PATH.pub"
echo ""
echo "Add this key to:"
echo "  Github: https://github.com/settings/ssh/new"
echo "  Gitee:  https://gitee.com/profile/sshkeys"
