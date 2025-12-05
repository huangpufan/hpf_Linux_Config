#!/usr/bin/env bash
# tools/snap/procs.sh - procs 安装脚本 (ps alternative)
# https://github.com/dalance/procs
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="procs"
TOOL_CMD="procs"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    if ! bash "$SCRIPT_DIR/_ensure.sh"; then
        log_warn "Snap not available, skipping $TOOL_NAME installation"
        return 1
    fi
    sudo snap install procs
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed"
        return 0
    fi
    
    log_info "Installing $TOOL_NAME..."
    do_install
    log_info "$TOOL_NAME installed successfully"
}

main "$@"

