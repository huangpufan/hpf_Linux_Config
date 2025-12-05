#!/usr/bin/env bash
# tools/cargo/_ensure.sh - 确保 cargo/rust 环境可用
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

# 加载 cargo 环境
load_cargo() {
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.cargo/env"
    fi
}

# 安装 rust/cargo
install_rust() {
    log_info "Installing Rust and Cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    load_cargo
}

# 配置 cargo 镜像源（中国用户加速）
configure_cargo_registry() {
    local config_dir="$HOME/.cargo"
    local config_file="$config_dir/config"
    local repo_config="$REPO_ROOT/basic/cargo-config"
    
    # 如果配置文件不存在且仓库配置存在，创建符号链接
    if [ ! -L "$config_file" ] && [ ! -e "$config_file" ] && [ -e "$repo_config" ]; then
        mkdir -p "$config_dir"
        ln -s "$repo_config" "$config_file"
        log_info "Cargo config linked to repo config"
    fi
}

# 检查 cargo 是否可用
ensure_cargo() {
    load_cargo
    
    if command -v cargo >/dev/null 2>&1; then
        log_info "cargo is available: $(cargo --version)"
        return 0
    fi
    
    install_rust
    
    if command -v cargo >/dev/null 2>&1; then
        log_info "cargo installed: $(cargo --version)"
        return 0
    fi
    
    log_err "Failed to install cargo"
    return 1
}

# 主逻辑
main() {
    ensure_cargo
    configure_cargo_registry
}

main "$@"

