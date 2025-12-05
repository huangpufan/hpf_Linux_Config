#!/usr/bin/env bash
# setup/cargo-registry.sh - 配置 cargo 镜像源
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

configure_registry() {
    local config_dir="$HOME/.cargo"
    local config_file="$config_dir/config"
    local repo_config="$REPO_ROOT/basic/cargo-config"
    
    # 加载 cargo 环境
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.cargo/env"
    fi
    
    if ! command -v cargo >/dev/null 2>&1; then
        log_warn "cargo is not installed, skipping registry configuration"
        return 0
    fi
    
    # 如果配置文件不存在且仓库配置存在，创建符号链接
    if [ ! -L "$config_file" ] && [ ! -e "$config_file" ] && [ -e "$repo_config" ]; then
        mkdir -p "$config_dir"
        ln -s "$repo_config" "$config_file"
        log_info "Cargo config linked to repo config"
    else
        log_info "Cargo config already exists"
    fi
}

main() {
    configure_registry
}

main "$@"

