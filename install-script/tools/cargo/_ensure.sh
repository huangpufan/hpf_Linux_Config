#!/usr/bin/env bash
# tools/cargo/_ensure.sh - 确保 cargo/rustup 环境并配置镜像源
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

# 确保 cargo 已安装
ensure_cargo() {
    # 加载 cargo 环境（如果存在）
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.cargo/env"
    fi
    
    if command -v cargo >/dev/null 2>&1; then
        log_info "cargo is already installed: $(cargo --version)"
        return 0
    fi
    
    log_info "Installing rustup and cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # 重新加载环境
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.cargo/env"
    fi
    
    if ! command -v cargo >/dev/null 2>&1; then
        log_err "Failed to install cargo"
        return 1
    fi
    
    log_info "cargo installed successfully: $(cargo --version)"
}

# 配置 cargo 镜像源（使用 rsproxy.cn）
configure_cargo_registry() {
    local config_dir="$HOME/.cargo"
    local config_file="$config_dir/config.toml"
    local old_config="$config_dir/config"
    local repo_config="$REPO_ROOT/basic/cargo-config.toml"
    
    # 移除旧的 config 链接（已弃用）
    if [ -L "$old_config" ]; then
        rm -f "$old_config"
        log_info "Removed deprecated config symlink"
    fi
    
    # 如果配置文件不存在且仓库配置存在，创建符号链接
    if [ ! -L "$config_file" ] && [ ! -e "$config_file" ] && [ -e "$repo_config" ]; then
        mkdir -p "$config_dir"
        ln -s "$repo_config" "$config_file"
        log_info "Cargo config.toml linked to repo config"
    else
        log_info "Cargo config already exists or repo config not found"
    fi
}

# 如果直接运行此脚本，执行 ensure 和 configure
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ensure_cargo
    configure_cargo_registry
fi
