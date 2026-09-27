#!/usr/bin/env bash
# tools/agent/_ensure.sh - 确保 Agent CLI 安装所需的运行时可用
#
# 本文件只负责“准备好安装条件”，不负责安装具体 Agent。
# 与 tools/npm/_ensure.sh 保持一致的做法：被 source 时即执行检查。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

# 加载 nvm 环境（Agent CLI 多数是 npm 全局包）
load_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
}

# 中国网络下必须用镜像源，否则装 npm 包会超时
configure_npm_registry() {
    local current
    current="$(npm config get registry 2>/dev/null || true)"
    if [ "$current" != "https://registry.npmmirror.com" ]; then
        npm config set registry https://registry.npmmirror.com
        log_info "npm registry set to https://registry.npmmirror.com"
    fi
}

# 有些 Agent 包的原生二进制靠 postinstall 装配（实测：@anthropic-ai/claude-code、
# opencode-ai、agent-browser）。npm 默认**禁止** install scripts，会导致装完
# 只有一个 500 字节的 shim，运行时才报 "native binary not installed"。
#
# 两个坑（都已实测）：
#   1. `npm install-scripts approve` 对**全局安装无效** —— npm 源码直接报
#      "does not work for global installs"。全局安装只能靠 .npmrc 的配置。
#   2. `allow-scripts` **没有通配符**（`*` 会被当作非法版本范围丢弃），
#      必须逐个列包名；裸包名表示该包任意版本都放行。
configure_npm_allow_scripts() {
    local wanted="@anthropic-ai/claude-code,opencode-ai,agent-browser"
    local current
    current="$(npm config get allow-scripts 2>/dev/null || true)"
    if [ "$current" != "$wanted" ]; then
        npm config set allow-scripts="$wanted" --location=user
        log_info "npm allow-scripts configured for packages needing postinstall"
    fi
}

ensure_npm() {
    load_nvm

    if ! command -v npm >/dev/null 2>&1; then
        log_err "npm is not installed. Agent CLI（npm 类）需要 Node.js/npm。"
        log_info "先安装 nvm：python3 install-script/agent-runner.py install nvm"
        return 1
    fi

    log_info "npm is available: $(npm --version)"
    configure_npm_registry
    configure_npm_allow_scripts
}

ensure_curl() {
    if ! command -v curl >/dev/null 2>&1; then
        log_err "curl is not installed（curl 类 Agent 安装脚本需要它）"
        return 1
    fi
}

main() {
    ensure_npm
}

main "$@"
