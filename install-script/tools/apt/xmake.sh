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
    # Ubuntu 24.04 already ships xmake; prefer distro packages over the PPA,
    # because Launchpad PPA downloads are often unstable in WSL/network-limited environments.
    if [ "$(ubuntu_version_id)" = "24.04" ]; then
        sudo apt update
        sudo apt-get install -y xmake/noble
        return 0
    fi

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
