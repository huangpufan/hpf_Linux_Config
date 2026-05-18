#!/usr/bin/env bash
# setup/git-identity.sh - configure git user.name and user.email
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

NAME_INPUT="${HPF_GIT_NAME:-}"
EMAIL_INPUT="${HPF_GIT_EMAIL:-}"

usage() {
    cat <<'EOF'
Usage:
  git-identity.sh [--name <git-name>] [--email <git-email>]

Environment fallback:
  HPF_GIT_NAME
  HPF_GIT_EMAIL

If neither flags nor environment variables are provided, the script reuses the
current global git identity when present. Otherwise it exits with an error.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --name)
            NAME_INPUT="${2:-}"
            shift 2
            ;;
        --email)
            EMAIL_INPUT="${2:-}"
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

CURRENT_NAME="$(git config --global user.name 2>/dev/null || true)"
CURRENT_EMAIL="$(git config --global user.email 2>/dev/null || true)"

if [ -z "$NAME_INPUT" ]; then
    NAME_INPUT="$CURRENT_NAME"
fi
if [ -z "$EMAIL_INPUT" ]; then
    EMAIL_INPUT="$CURRENT_EMAIL"
fi

if [ -z "$NAME_INPUT" ] || [ -z "$EMAIL_INPUT" ]; then
    log_err "git identity is incomplete"
    log_info "Provide --name/--email or set HPF_GIT_NAME and HPF_GIT_EMAIL"
    exit 1
fi

case "$EMAIL_INPUT" in
    *@*)
        ;;
    *)
        log_err "Invalid email address: $EMAIL_INPUT"
        exit 1
        ;;
esac

git config --global user.name "$NAME_INPUT"
git config --global user.email "$EMAIL_INPUT"

log_info "Configured git identity"
log_info "user.name=$NAME_INPUT"
log_info "user.email=$EMAIL_INPUT"
