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
    fi
}

# 更新 rust 工具链到最新稳定版
update_rust() {
    # 如果 rustup 存在，直接更新
    if command -v rustup >/dev/null 2>&1; then
        log_info "Updating Rust toolchain via rustup..."
        rustup update stable
        load_cargo
        log_info "Rust updated: $(cargo --version)"
    else
        # rustup 不存在，需要安装 rustup（会覆盖系统版本）
        log_info "Installing rustup to get latest Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        load_cargo
        # 确保 PATH 优先使用 ~/.cargo/bin
        export PATH="$HOME/.cargo/bin:$PATH"
        log_info "Rust installed via rustup: $(cargo --version)"
    fi
}

# 检查版本是否足够新（需要 1.85+ 支持 edition2024）
check_version_outdated() {
    local version major minor
    version=$(cargo --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)
    # 需要 1.85+
    if [ "$major" -lt 1 ]; then
        return 0  # outdated
    elif [ "$major" -eq 1 ] && [ "$minor" -lt 85 ]; then
        return 0  # outdated
    fi
    return 1  # OK
}

# 检查 cargo 是否可用
ensure_cargo() {
    # 优先加载 rustup 安装的 cargo
    export PATH="$HOME/.cargo/bin:$PATH"
    load_cargo
    
    if command -v cargo >/dev/null 2>&1; then
        log_info "cargo is available: $(cargo --version)"
        if check_version_outdated; then
            log_warn "Cargo is outdated (need 1.85+ for edition2024), updating..."
            update_rust
        fi
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

