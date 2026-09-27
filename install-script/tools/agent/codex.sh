#!/usr/bin/env bash
# tools/agent/codex.sh - OpenAI Codex CLI 安装脚本
# https://www.npmjs.com/package/@openai/codex
#
# 认证：两种模式。
#   1) ChatGPT 登录（推荐）：凭据落在明文文件 ~/.codex/auth.json，
#      无设备绑定，可随文件搬走。但 refresh token 是一次性轮换的，
#      两台机器共用同一份 auth.json 会互相失效。
#      无头环境重新登录用：codex login --device-auth
#   2) API key：printenv OPENAI_API_KEY | codex login --with-api-key
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="codex"
TOOL_CMD="codex"
NPM_PACKAGE="@openai/codex"

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
        log_info "登录：codex login（有浏览器）或 codex login --device-auth（无头）"
    else
        log_err "$TOOL_NAME install failed"
        return 1
    fi
}

main "$@"
