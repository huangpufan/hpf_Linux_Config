#!/usr/bin/env bash
# tools/cargo/fd.sh - fd 安装脚本 (find 的现代替代品，cargo 最新版)
# https://github.com/sharkdp/fd
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="fd"
TOOL_CMD="fd"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    source "$SCRIPT_DIR/_ensure.sh"
    ensure_cargo
    configure_cargo_registry

    # 如果 apt 版 fd-find 存在，先移除避免冲突
    if command -v fdfind >/dev/null 2>&1; then
        log_info "Removing apt fd-find to avoid conflict..."
        sudo apt remove -y fd-find 2>/dev/null || true
    fi
    rm -f ~/.local/bin/fd

    cargo install fd-find
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
