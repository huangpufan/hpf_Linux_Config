#!/usr/bin/env bash
set -Eeuo pipefail

SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
SSH_KEY_PUB="${SSH_KEY_PATH}.pub"
SSH_COMMENT="$(git config --global user.email 2>/dev/null || true)"

if [ -z "$SSH_COMMENT" ]; then
    SSH_COMMENT="59730801@qq.com"
fi

mkdir -p "$HOME/.ssh"

if [ -f "$SSH_KEY_PUB" ]; then
    echo "SSH key already exists at $SSH_KEY_PUB"
else
    echo "Generating new SSH key at $SSH_KEY_PATH ..."
    ssh-keygen -t ed25519 -C "$SSH_COMMENT" -f "$SSH_KEY_PATH" -q -N ""
    echo "SSH key generated successfully!"
fi

echo ""
echo "Your SSH public key:"
cat "$SSH_KEY_PUB"
echo ""
echo "Next step:"
echo "  For GitHub, prefer: bash ~/hpf_Linux_Config/install-script/setup/github-ssh.sh"
