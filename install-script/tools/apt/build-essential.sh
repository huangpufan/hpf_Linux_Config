#!/usr/bin/env bash
# tools/apt/build-essential.sh - build-essential 安装脚本 (compiler toolchain)
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="build-essential"
TOOL_CMD="gcc"

is_installed() {
    dpkg -l | grep -qw build-essential 2>/dev/null
}

do_install() {
    apt_install build-essential
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

