#!/usr/bin/env bash
# setup/github-ssh.sh - optional GitHub SSH bootstrap via gh
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

HOSTNAME="${GITHUB_HOSTNAME:-github.com}"
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
SSH_KEY_TITLE="${SSH_KEY_TITLE:-$(hostname)-${USER}-hpf-linux-config}"

usage() {
    cat <<'EOF'
Usage:
  github-ssh.sh [--hostname <host>] [--key-path <path>] [--title <key-title>]

The script assumes `gh` is already authenticated to the host.
It creates an SSH key if needed, uploads it with `gh ssh-key add`, and switches
gh git protocol to ssh.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --hostname)
            HOSTNAME="${2:-}"
            shift 2
            ;;
        --key-path)
            SSH_KEY_PATH="${2:-}"
            shift 2
            ;;
        --title)
            SSH_KEY_TITLE="${2:-}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_err "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

require_cmd gh
require_cmd ssh-keygen

if ! gh auth status --hostname "$HOSTNAME" >/dev/null 2>&1; then
    log_err "gh is not authenticated for $HOSTNAME"
    log_info "Run setup/github-auth.sh first"
    exit 1
fi

SSH_KEY_PUB="${SSH_KEY_PATH}.pub"
SSH_COMMENT="$(git config --global user.email 2>/dev/null || true)"
if [ -z "$SSH_COMMENT" ]; then
    SSH_COMMENT="59730801@qq.com"
fi

mkdir -p "$(dirname "$SSH_KEY_PATH")"

if [ ! -f "$SSH_KEY_PUB" ]; then
    log_info "Generating SSH key at $SSH_KEY_PATH"
    ssh-keygen -t ed25519 -C "$SSH_COMMENT" -f "$SSH_KEY_PATH" -q -N ""
else
    log_info "SSH key already exists at $SSH_KEY_PUB"
fi

if gh ssh-key list | grep -F "$SSH_KEY_TITLE" >/dev/null 2>&1; then
    log_info "GitHub already has an SSH key titled '$SSH_KEY_TITLE'"
else
    log_info "Uploading SSH key to GitHub as '$SSH_KEY_TITLE'"
    gh ssh-key add "$SSH_KEY_PUB" --title "$SSH_KEY_TITLE"
fi

gh config set git_protocol ssh --host "$HOSTNAME"
gh auth setup-git --hostname "$HOSTNAME"

CURRENT_PROTOCOL="$(gh config get git_protocol --host "$HOSTNAME" 2>/dev/null || true)"
if [ "$CURRENT_PROTOCOL" != "ssh" ]; then
    log_err "Failed to switch gh git protocol to ssh"
    exit 1
fi

log_info "GitHub SSH is ready for $HOSTNAME"
log_info "key=$SSH_KEY_PUB"
