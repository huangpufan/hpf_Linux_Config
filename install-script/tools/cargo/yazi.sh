#!/usr/bin/env bash
# tools/cargo/yazi.sh - yazi 安装脚本 (terminal file manager)
# https://github.com/sxyazi/yazi
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="yazi"
TOOL_CMD="yazi"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # 使用 source 确保 PATH 设置生效
    source "$SCRIPT_DIR/_ensure.sh"
    cargo install --locked yazi-fm yazi-cli
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

