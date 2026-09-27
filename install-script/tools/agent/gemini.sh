#!/usr/bin/env bash
# tools/agent/gemini.sh - Google Gemini CLI 安装脚本
# https://www.npmjs.com/package/@google/gemini-cli
#
# 认证：OAuth（浏览器）或 GEMINI_API_KEY。
# 状态目录 ~/.gemini/（含 installation_id 与 oauth token 文件）。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="gemini"
TOOL_CMD="gemini"
NPM_PACKAGE="@google/gemini-cli"

is_installed() {
    # 不能只看 `command -v`：runner 执行本脚本时用的是**非交互 shell**，PATH 里
    # 没有 ~/.local/bin（那是 Ubuntu 的 .profile 给登录 shell 加的），而 npm 的
    # 全局前缀已被 _ensure.sh 统一设成 ~/.local —— 结果会误判"没装"。
    command -v "$TOOL_CMD" >/dev/null 2>&1 || [ -x "$HOME/.local/bin/$TOOL_CMD" ]
}

do_install() {
    # shellcheck source=./_ensure.sh
    . "$SCRIPT_DIR/_ensure.sh"

    npm install --global "$NPM_PACKAGE"
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed ($("$TOOL_CMD" --version 2>/dev/null || echo '?'))"
        return 0
    fi

    log_info "Installing $TOOL_NAME ($NPM_PACKAGE)..."
    do_install

    if is_installed; then
        log_info "$TOOL_NAME installed successfully"
    else
        log_err "$TOOL_NAME install failed"
        return 1
    fi
}

main "$@"
