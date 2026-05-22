#!/usr/bin/env bash
# tools/curl/herdr.sh - Herdr 安装脚本 (terminal workspace manager for AI coding agents)
# https://herdr.dev
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="herdr"
TOOL_CMD="herdr"
INSTALL_SCRIPT_URL="https://herdr.dev/install.sh"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    curl -fsSL "$INSTALL_SCRIPT_URL" | sh
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
