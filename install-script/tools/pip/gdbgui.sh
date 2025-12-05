#!/usr/bin/env bash
# tools/pip/gdbgui.sh - gdbgui 安装脚本 (browser-based gdb frontend)
# https://www.gdbgui.com/
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="gdbgui"
TOOL_CMD="gdbgui"

is_installed() {
    pipx list 2>/dev/null | grep -q gdbgui
}

do_install() {
    bash "$SCRIPT_DIR/_ensure.sh"
    
    # 确保 pipx 在 PATH 中
    export PATH="$HOME/.local/bin:$PATH"
    
    pipx install gdbgui --force || {
        log_warn "gdbgui installation failed"
        return 1
    }
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed via pipx"
        return 0
    fi
    
    log_info "Installing $TOOL_NAME..."
    do_install
    log_info "$TOOL_NAME installed successfully"
}

main "$@"

