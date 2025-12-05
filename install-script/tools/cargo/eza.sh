#!/usr/bin/env bash
# tools/cargo/eza.sh - eza 安装脚本 (modern ls replacement)
# https://github.com/eza-community/eza
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="eza"
TOOL_CMD="eza"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # 使用 source 加载函数并确保 PATH 设置生效
    source "$SCRIPT_DIR/_ensure.sh"
    ensure_cargo
    configure_cargo_registry
    cargo install eza
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

