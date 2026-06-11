#!/usr/bin/env bash
# tools/cargo/bat.sh - bat 安装脚本 (cat 替代品，cargo 最新版)
# https://github.com/sharkdp/bat
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="bat"
TOOL_CMD="bat"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    source "$SCRIPT_DIR/_ensure.sh"
    ensure_cargo
    configure_cargo_registry

    # 如果 apt 版 bat 存在，先移除避免冲突
    if command -v batcat >/dev/null 2>&1; then
        log_info "Removing apt bat to avoid conflict..."
        sudo apt remove -y bat 2>/dev/null || true
    fi
    rm -f ~/.local/bin/bat

    cargo install bat
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed"
        return 0
    fi

    log_info "Installing $TOOL_NAME (cargo latest)..."
    do_install
    log_info "$TOOL_NAME installed successfully"
}

main "$@"
