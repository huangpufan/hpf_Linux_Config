#!/usr/bin/env bash
# tools/cargo/yazi.sh - yazi 安装脚本 (terminal file manager)
# https://github.com/sxyazi/yazi
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="yazi"
TOOL_CMD="yazi"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # 使用 source 加载函数并确保 PATH 设置生效
    source "$SCRIPT_DIR/_ensure.sh"
    ensure_cargo
    configure_cargo_registry

    if cargo install --locked yazi-fm yazi-cli; then
        return 0
    fi

    log_warn "Cargo install failed; falling back to official GitHub release .deb"
    local download_dir="$HOME/download/yazi"
    mkdir -p "$download_dir"
    rm -f "$download_dir"/yazi-*.deb

    if command -v gh >/dev/null 2>&1; then
        gh release download --repo sxyazi/yazi --pattern 'yazi-x86_64-unknown-linux-gnu.deb' --clobber --dir "$download_dir"
    else
        curl -L -o "$download_dir/yazi-x86_64-unknown-linux-gnu.deb" \
            https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.deb
    fi

    sudo apt-get install -y "$download_dir"/yazi-x86_64-unknown-linux-gnu.deb
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
