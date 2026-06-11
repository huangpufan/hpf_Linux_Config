#!/usr/bin/env bash
# tools/apt/yq.sh - yq 安装脚本 (YAML 处理器，mikefarah/yq Go 版)
# https://github.com/mikefarah/yq
# 注意：apt 的 python3-yq 是 jq 封装器，功能不全。
# 这里使用 snap 安装独立的 Go 版 yq。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="yq"
TOOL_CMD="yq"

is_installed() {
    # 检查是否为 mikefarah/yq (Go 版)，排除 python3-yq 封装器
    if command -v "$TOOL_CMD" >/dev/null 2>&1; then
        local version_output
        version_output=$("$TOOL_CMD" --version 2>/dev/null || true)
        # mikefarah/yq 输出 "yq (https://github.com/mikefarah/yq/) version v4.x"
        # python3-yq 输出 "yq 0.0.0"
        if echo "$version_output" | grep -qi "mikefarah"; then
            return 0
        fi
        # 如果 version 包含数字但非 "0.0.0" 也算
        if ! echo "$version_output" | grep -q "0\.0\.0"; then
            return 0
        fi
    fi
    return 1
}

do_install() {
    # 先移除 apt 的 python3-yq（如果有）
    if dpkg -l | grep -q "python3-yq\|yq" 2>/dev/null; then
        log_info "Removing apt python3-yq wrapper..."
        sudo apt remove -y yq python3-yq 2>/dev/null || true
    fi

    # 使用 snap 安装 mikefarah/yq
    if command -v snap >/dev/null 2>&1; then
        log_info "Installing mikefarah/yq via snap..."
        sudo snap install yq
    else
        log_err "Snap not available; cannot install mikefarah/yq"
        return 1
    fi
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME (mikefarah/yq) is already installed"
        return 0
    fi

    log_info "Installing $TOOL_NAME (mikefarah/yq)..."
    do_install
    log_info "$TOOL_NAME installed successfully"
}

main "$@"
