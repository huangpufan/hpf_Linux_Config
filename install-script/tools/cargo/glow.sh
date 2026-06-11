#!/usr/bin/env bash
# tools/cargo/glow.sh - glow 安装脚本 (终端 Markdown 渲染)
# https://github.com/charmbracelet/glow
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="glow"
TOOL_CMD="glow"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    source "$SCRIPT_DIR/_ensure.sh"
    ensure_cargo
    configure_cargo_registry
    cargo install glow
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
