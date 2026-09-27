#!/usr/bin/env bash
# tools/agent/claude.sh - Claude Code 安装脚本
# https://www.npmjs.com/package/@anthropic-ai/claude-code
#
# 认证：三种方式，按环境选。
#   1) Anthropic 账号 OAuth：claude 里执行 /login（需要浏览器）
#   2) API key：环境变量 ANTHROPIC_API_KEY
#   3) 第三方兼容网关：ANTHROPIC_BASE_URL + ANTHROPIC_AUTH_TOKEN
#      （本机走的就是这条：cc-switch 本地网关 → 火山方舟）
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="claude"
TOOL_CMD="claude"
NPM_PACKAGE="@anthropic-ai/claude-code"

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
        log_info "$TOOL_NAME is already installed ($("$TOOL_CMD" --version 2>/dev/null | head -1 || echo '?'))"
        return 0
    fi

    log_info "Installing $TOOL_NAME ($NPM_PACKAGE)..."
    do_install

    if is_installed; then
        log_info "$TOOL_NAME installed successfully"
        log_info "配置：ANTHROPIC_BASE_URL + ANTHROPIC_AUTH_TOKEN，或在 claude 内执行 /login"
    else
        log_err "$TOOL_NAME install failed"
        return 1
    fi
}

main "$@"
