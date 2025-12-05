#!/usr/bin/env bash
# tools/curl/fzf.sh - fzf 安装脚本 (fuzzy finder)
# https://github.com/junegunn/fzf
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="fzf"
TOOL_CMD="fzf"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # 检查 fzf 安装脚本是否存在
    if [ -f ~/.fzf/install ]; then
        log_info "fzf directory exists, running install script"
        ~/.fzf/install --all
        return 0
    fi
    
    # 清理不完整的目录
    if [ -d ~/.fzf ]; then
        log_info "Removing incomplete fzf directory"
        rm -rf ~/.fzf
    fi
    
    # 克隆仓库
    if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; then
        ~/.fzf/install --all
    else
        log_err "Failed to clone fzf repository"
        [ -d ~/.fzf ] && rm -rf ~/.fzf
        return 1
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
    log_info "Please run 'source ~/.bashrc' or restart your terminal"
}

main "$@"

