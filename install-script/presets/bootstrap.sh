#!/usr/bin/env bash
# presets/bootstrap.sh - prepare machine basics before downloading tools
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

HOSTNAME="${GITHUB_HOSTNAME:-github.com}"
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
SSH_KEY_TITLE="${SSH_KEY_TITLE:-$(hostname)-${USER}-hpf-linux-config}"
BROAD_GH_SCOPES="${BROAD_GH_SCOPES:-admin:public_key,admin:ssh_signing_key,workflow,admin:repo_hook,user}"

ensure_ssh_key() {
    local pubkey="${SSH_KEY_PATH}.pub"
    local comment

    comment="$(git config --global user.email 2>/dev/null || true)"
    if [ -z "$comment" ]; then
        comment="59730801@qq.com"
    fi

    mkdir -p "$(dirname "$SSH_KEY_PATH")"
    if [ -f "$pubkey" ]; then
        log_info "SSH key already exists at $pubkey"
        return 0
    fi

    log_info "Generating SSH key at $SSH_KEY_PATH"
    ssh-keygen -t ed25519 -C "$comment" -f "$SSH_KEY_PATH" -q -N ""
}

configure_git_identity_if_known() {
    if git config --global user.name >/dev/null 2>&1 &&
       git config --global user.email >/dev/null 2>&1; then
        bash "$REPO_ROOT/setup/git-identity.sh"
        return 0
    fi

    if [ -n "${HPF_GIT_NAME:-}" ] && [ -n "${HPF_GIT_EMAIL:-}" ]; then
        bash "$REPO_ROOT/setup/git-identity.sh"
        return 0
    fi

    log_warn "Git identity is not configured; set HPF_GIT_NAME and HPF_GIT_EMAIL to configure it automatically"
}

authenticate_github_for_ssh() {
    local status_output scope missing_scope

    if gh auth status --hostname "$HOSTNAME" >/dev/null 2>&1; then
        log_info "gh is already authenticated for $HOSTNAME"
    else
        log_info "Starting gh web login before SSH key upload"
        GITHUB_GIT_PROTOCOL=https bash "$REPO_ROOT/setup/github-auth.sh" \
            --hostname "$HOSTNAME" \
            --git-protocol https
    fi

    status_output="$(gh auth status --hostname "$HOSTNAME" 2>&1 || true)"
    missing_scope=0
    IFS=',' read -r -a requested_scopes <<< "$BROAD_GH_SCOPES"
    for scope in "${requested_scopes[@]}"; do
        scope="${scope#"${scope%%[![:space:]]*}"}"
        scope="${scope%"${scope##*[![:space:]]}"}"
        if ! grep -qF "'$scope'" <<< "$status_output"; then
            missing_scope=1
            break
        fi
    done

    if [ "$missing_scope" -eq 1 ]; then
        log_info "Refreshing gh scopes for SSH key and future gh operations"
        gh auth refresh -h "$HOSTNAME" -s "$BROAD_GH_SCOPES" || \
            log_warn "gh auth refresh failed; continuing with existing token scopes"
    else
        log_info "gh token already has requested bootstrap scopes"
    fi

    SSH_KEY_TITLE="$SSH_KEY_TITLE" SSH_KEY_PATH="$SSH_KEY_PATH" \
        bash "$REPO_ROOT/setup/github-ssh.sh" --hostname "$HOSTNAME"
}

log_info "=========================================="
log_info "  Bootstrapping Machine Prerequisites"
log_info "=========================================="

bash "$REPO_ROOT/basic/folder-create.sh"
bash "$REPO_ROOT/basic/bashrc-init.sh"

log_info "Ensuring git and gh are available before GitHub setup..."
bash "$TOOLS_DIR/apt/git.sh"
bash "$TOOLS_DIR/apt/gh.sh"

configure_git_identity_if_known
ensure_ssh_key
authenticate_github_for_ssh

bash "$REPO_ROOT/setup/npm-registry.sh" || true
bash "$REPO_ROOT/setup/cargo-registry.sh" || true

log_info "=========================================="
log_info "  Bootstrap Complete"
log_info "=========================================="
