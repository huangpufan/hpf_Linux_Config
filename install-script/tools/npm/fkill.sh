#!/usr/bin/env bash
# tools/npm/fkill.sh - fkill-cli 安装脚本
# https://github.com/sindresorhus/fkill-cli
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="fkill"
TOOL_CMD="fkill"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # 确保 npm 环境
    bash "$SCRIPT_DIR/_ensure.sh"
    
    npm install --global fkill-cli
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

