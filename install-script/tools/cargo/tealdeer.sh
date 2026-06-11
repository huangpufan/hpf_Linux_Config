#!/usr/bin/env bash
# tools/cargo/tealdeer.sh - tealdeer 安装脚本 (快速 tldr 客户端)
# https://github.com/dbrgn/tealdeer
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="tealdeer"
TOOL_CMD="tldr"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    source "$SCRIPT_DIR/_ensure.sh"
    ensure_cargo
    configure_cargo_registry
    cargo install tealdeer

    # tealdeer 安装后默认也是 tldr 命令，缓存帮助页
    if command -v tldr >/dev/null 2>&1; then
        tldr --update 2>/dev/null || true
    fi
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
