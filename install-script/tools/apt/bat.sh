#!/usr/bin/env bash
# tools/apt/bat.sh - bat 安装脚本 (cat with syntax highlighting)
# https://github.com/sharkdp/bat
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="bat"
TOOL_CMD="bat"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1
}

do_install() {
    apt_install bat
    
    # Ubuntu 中包名为 batcat，创建符号链接
    if command -v batcat >/dev/null 2>&1 && [ ! -L ~/.local/bin/bat ]; then
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
        log_info "Created symlink: bat -> batcat"
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

