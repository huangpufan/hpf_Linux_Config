#!/usr/bin/env bash
# setup/cargo-registry.sh - 配置 cargo 镜像源
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

configure_registry() {
    local config_dir="$HOME/.cargo"
    local config_file="$config_dir/config.toml"
    local old_config="$config_dir/config"
    local repo_config="$REPO_ROOT/home/.cargo/config.toml"

    # 加载 cargo 环境
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.cargo/env"
    fi

    if [ ! -f "$repo_config" ]; then
        log_err "repo cargo config not found: $repo_config"
        return 1
    fi

    mkdir -p "$config_dir"

    # 移除旧的 config 链接（已弃用）
    if [ -L "$old_config" ]; then
        rm -f "$old_config"
        log_info "Removed deprecated config symlink"
    fi

    if [ -L "$config_file" ] && [ "$(readlink "$config_file")" = "$repo_config" ]; then
        log_info "Cargo config.toml already linked to repo config"
        return 0
    fi

    if [ ! -e "$config_file" ]; then
        ln -s "$repo_config" "$config_file"
        log_info "Cargo config.toml linked to repo config"
        return 0
    fi

    if grep -q "rsproxy.cn" "$config_file"; then
        log_info "Cargo config already contains rsproxy.cn registry"
        return 0
    fi

    log_err "Cargo config exists but does not contain the repo registry: $config_file"
    log_err "Move it aside or add rsproxy.cn manually before rerunning this tool"
    return 1
}

main() {
    configure_registry
}

main "$@"
