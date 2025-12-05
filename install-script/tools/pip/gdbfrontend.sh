#!/usr/bin/env bash
# tools/pip/gdbfrontend.sh - gdbfrontend 安装脚本 (gdb frontend)
# https://github.com/rohanrhu/gdb-frontend
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="gdbfrontend"
TSINGHUA_MIRROR="-i https://pypi.tuna.tsinghua.edu.cn/simple"

is_installed() {
    python3 -m gdbfrontend --version >/dev/null 2>&1
}

do_install() {
    bash "$SCRIPT_DIR/_ensure.sh"
    sudo python3 -m pip install gdbfrontend $TSINGHUA_MIRROR || {
        log_warn "gdbfrontend installation failed"
        return 1
    }
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

