#!/usr/bin/env bash
# tools/agent/kimi.sh - Kimi Code CLI 安装脚本
# 官方安装：curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash
#
# 安装布局：装在 ~/.kimi-code/（bin/ 下是可执行文件，约 350M），
# 安装脚本会把 ~/.kimi-code/bin 追加进 ~/.bashrc 的 PATH。
# 因为 PATH 改动只对新 shell 生效，本脚本的校验会同时看 PATH 和固定路径。
#
# 认证：OAuth，凭据在 ~/.kimi-code/credentials/，另有 ~/.kimi-code/device_id。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="kimi"
INSTALL_URL="https://code.kimi.com/kimi-code/install.sh"
KIMI_BIN="$HOME/.kimi-code/bin/kimi"

is_installed() {
    command -v kimi >/dev/null 2>&1 || [ -x "$KIMI_BIN" ]
}

do_install() {
    # shellcheck source=./_ensure.sh
    . "$SCRIPT_DIR/_ensure.sh"
    ensure_curl

    # 与 devin 同样的问题：官方安装器在最后会**自动启动一次交互式登录**，
    # 在非交互环境（Docker 构建、CI、远程自动化）里那一步会被取消并让整个
    # 步骤返回非零 —— 但此时二进制已经装好了。所以落盘后以 </dev/null 执行并
    # 容错，真正的判定交给 main() 的 is_installed。
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
        log_info "$TOOL_NAME is already installed"
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install

    if is_installed; then
        log_info "$TOOL_NAME installed successfully"
        if ! command -v kimi >/dev/null 2>&1; then
            log_warn "kimi 尚未在当前 shell 的 PATH 中，重新登录 shell 后生效（或 source ~/.bashrc）"
        fi
    else
        log_err "$TOOL_NAME install failed"
        return 1
    fi
}

main "$@"
