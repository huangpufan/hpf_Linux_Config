#!/usr/bin/env bash
# setup/github-auth.sh - authenticate GitHub CLI and default git to HTTPS
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

HOSTNAME="${GITHUB_HOSTNAME:-github.com}"
GIT_PROTOCOL="${GITHUB_GIT_PROTOCOL:-https}"

usage() {
    cat <<'EOF'
Usage:
  github-auth.sh [--hostname <host>] [--git-protocol <https|ssh>]

Defaults:
  --hostname github.com
  --git-protocol https

The script uses `gh auth login --web` when the host is not authenticated yet,
then configures `gh` as the git credential helper via `gh auth setup-git`.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --hostname)
            HOSTNAME="${2:-}"
            shift 2
            ;;
        --git-protocol)
            GIT_PROTOCOL="${2:-}"
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

case "$GIT_PROTOCOL" in
    https|ssh)
        ;;
    *)
        log_err "Unsupported git protocol: $GIT_PROTOCOL"
        exit 1
        ;;
esac

require_cmd gh
require_cmd git

if gh auth status --hostname "$HOSTNAME" >/dev/null 2>&1; then
    log_info "gh is already authenticated for $HOSTNAME"
else
    log_info "Starting gh auth login for $HOSTNAME using $GIT_PROTOCOL"
    gh auth login --hostname "$HOSTNAME" --git-protocol "$GIT_PROTOCOL" --web
fi

gh config set git_protocol "$GIT_PROTOCOL" --host "$HOSTNAME"
gh auth setup-git --hostname "$HOSTNAME"

gh auth status --hostname "$HOSTNAME" >/dev/null
CURRENT_PROTOCOL="$(gh config get git_protocol --host "$HOSTNAME" 2>/dev/null || true)"

if [ "$CURRENT_PROTOCOL" != "$GIT_PROTOCOL" ]; then
    log_err "gh git protocol check failed: expected $GIT_PROTOCOL, got ${CURRENT_PROTOCOL:-<empty>}"
    exit 1
fi

log_info "gh authentication is ready for $HOSTNAME"
log_info "git_protocol=$CURRENT_PROTOCOL"
