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
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # shellcheck source=./_ensure.sh
    . "$SCRIPT_DIR/_ensure.sh"
    ensure_curl

    log_info "Running official installer: $INSTALL_URL"
    curl -fsSL "$INSTALL_URL" | bash
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
