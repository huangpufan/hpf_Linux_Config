#!/usr/bin/env bash
# tools/curl/lazygit.sh - lazygit 安装脚本 (terminal UI for git)
# https://github.com/jesseduffield/lazygit
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="lazygit"
TOOL_CMD="lazygit"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    local download_dir="${HOME}/download"
    mkdir -p "$download_dir"
    cd "$download_dir"
    
    # 获取最新版本号
    local version
    version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    
    if [ -z "$version" ]; then
        log_err "Failed to get latest version"
        return 1
    fi
    
    log_info "Downloading lazygit v$version..."
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
    
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    
    # 清理
    rm -rf lazygit lazygit.tar.gz
    cd ~
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

