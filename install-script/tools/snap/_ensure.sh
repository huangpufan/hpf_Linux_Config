#!/usr/bin/env bash
# tools/snap/_ensure.sh - 确保 snap 环境可用
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

# 检查 snap 是否可用
has_snap() {
    command -v snap >/dev/null 2>&1 && \
    (systemctl is-active snapd >/dev/null 2>&1 || snap version >/dev/null 2>&1)
}

ensure_snap() {
    if has_snap; then
        log_info "snap is available"
        return 0
    fi
    
    log_warn "Snap is not available (possibly running in container or WSL)"
    log_warn "Some tools may not be installable via snap"
    return 1
}

main() {
    ensure_snap
}

main "$@"

