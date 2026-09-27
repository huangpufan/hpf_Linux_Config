#!/usr/bin/env bash
# tools/agent/devin.sh - Devin CLI 安装脚本
# 官方安装：curl -fsSL https://cli.devin.ai/install.sh | bash
#
# 安装布局：版本装在 ~/.local/share/devin/cli/_versions/<version>/，
# 另有 current 软链；~/.local/bin/devin 指向它。自带 `devin update`。
#
# 认证：devin auth login（登录后可携带 ~/.local/share/devin/credentials.toml）。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="devin"
TOOL_CMD="devin"
INSTALL_URL="https://cli.devin.ai/install.sh"

is_installed() {
    # 不能只看 `command -v`：runner 执行本脚本时用的是**非交互 shell**，PATH 里
    # 没有 ~/.local/bin（那是 Ubuntu 的 .profile 给登录 shell 加的），而 npm 的
    # 全局前缀已被 _ensure.sh 统一设成 ~/.local —— 结果会误判"没装"。
    command -v "$TOOL_CMD" >/dev/null 2>&1 || [ -x "$HOME/.local/bin/$TOOL_CMD" ]
}

do_install() {
    # shellcheck source=./_ensure.sh
    . "$SCRIPT_DIR/_ensure.sh"
    ensure_curl

    # 先把安装器落盘再跑，并把 stdin 接到 /dev/null：官方安装器在最后会
    # **自动启动一次交互式登录**（打印 "Welcome to Devin CLI!"），在非交互环境
    # （Docker 构建、CI）里那一步会被取消，让整个步骤返回非零 —— 但此时二进制
    # 已经装好了。所以这里容错，真正的判定交给 main() 的 command -v devin。
    local installer
    installer="$(mktemp)"
    log_info "Running official installer: $INSTALL_URL"
    curl -fsSL "$INSTALL_URL" -o "$installer"
    if ! bash "$installer" </dev/null; then
        log_warn "安装器返回非零（通常是它启动的登录流程被取消）；继续按二进制是否存在判定"
    fi
    rm -f "$installer"
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed ($("$TOOL_CMD" --version 2>/dev/null | head -1 || echo '?'))"
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install

    if is_installed; then
        log_info "$TOOL_NAME installed successfully"
        log_info "登录：devin auth login"
    else
        log_warn "$TOOL_NAME not found on PATH. 确认 ~/.local/bin 在 PATH 里。"
        return 1
    fi
}

main "$@"
