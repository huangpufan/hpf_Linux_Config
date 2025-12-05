#!/usr/bin/env bash
# tools/curl/nvm.sh - nvm 安装脚本 (Node Version Manager)
# https://github.com/nvm-sh/nvm
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="nvm"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

is_installed() {
    [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]
}

do_install() {
    # 安装 nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # 加载 nvm
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # 安装 Node.js 18
    log_info "Installing Node.js 18..."
    nvm install 18
    nvm use 18
    nvm alias default v18
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

