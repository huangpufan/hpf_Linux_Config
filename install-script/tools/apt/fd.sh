#!/usr/bin/env bash
# tools/apt/fd.sh - fd 安装脚本 (find 的现代替代品)
# https://github.com/sharkdp/fd
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="fd"
TOOL_CMD="fd"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1
}

do_install() {
    apt_install fd-find

    # Ubuntu 中包名为 fd-find，创建符号链接
    if command -v fdfind >/dev/null 2>&1 && [ ! -L ~/.local/bin/fd ]; then
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/fdfind ~/.local/bin/fd
        log_info "Created symlink: fd -> fdfind"
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
