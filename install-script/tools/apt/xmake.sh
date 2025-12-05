#!/usr/bin/env bash
# tools/apt/xmake.sh - xmake 安装脚本 (build system)
# https://xmake.io/
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="xmake"
TOOL_CMD="xmake"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # 添加 xmake PPA
    sudo add-apt-repository -y ppa:xmake-io/xmake || {
        log_warn "Failed to add xmake PPA"
        return 1
    }
    apt_update_once
    apt_install xmake
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

