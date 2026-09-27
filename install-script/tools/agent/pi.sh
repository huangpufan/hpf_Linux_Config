#!/usr/bin/env bash
# tools/agent/pi.sh - pi coding agent 安装脚本
# https://www.npmjs.com/package/@earendil-works/pi-coding-agent
#
# 认证：明文 API key，存放于 ~/.pi/agent/auth.json 与 ~/.pi/agent/models.json。
# 这两个文件是可携带的，换机器时复制即可，不涉及 OAuth 或设备绑定。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="pi"
TOOL_CMD="pi"
NPM_PACKAGE="@earendil-works/pi-coding-agent"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
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
