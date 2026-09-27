#!/usr/bin/env bash
# tools/agent/cursor-agent.sh - Cursor CLI (cursor-agent) 安装脚本
# 官方安装：curl https://cursor.com/install -fsS | bash
#
# 安装布局：版本装在 ~/.local/share/cursor-agent/versions/<version>/，
# 并把 ~/.local/bin/cursor-agent 软链到当前版本。自带 `cursor-agent update`。
#
# 认证：OAuth，凭据在 ~/.config/cursor/auth.json（accessToken + refreshToken）。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="cursor-agent"
TOOL_CMD="cursor-agent"
INSTALL_URL="https://cursor.com/install"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # shellcheck source=./_ensure.sh
    . "$SCRIPT_DIR/_ensure.sh"
    ensure_curl

    log_info "Running official installer: $INSTALL_URL"
    curl "$INSTALL_URL" -fsS | bash
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed ($("$TOOL_CMD" --version 2>/dev/null || echo '?'))"
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install

    if is_installed; then
        log_info "$TOOL_NAME installed successfully"
    else
        log_warn "$TOOL_NAME not found on PATH. 官方脚本装在 ~/.local/bin，确认它在 PATH 里。"
        return 1
    fi
}

main "$@"
