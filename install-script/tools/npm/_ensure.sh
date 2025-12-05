#!/usr/bin/env bash
# tools/npm/_ensure.sh - 确保 npm 环境可用
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

# 加载 nvm 环境
load_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
}

# 检查 npm 是否可用
ensure_npm() {
    # 先尝试加载 nvm
    load_nvm
    
    if command -v npm >/dev/null 2>&1; then
        log_info "npm is available: $(npm --version)"
        return 0
    fi
    
    log_err "npm is not installed. Please install Node.js first."
    log_info "You can install nvm by running: bash tools/curl/nvm.sh"
    return 1
}

# 配置 npm 镜像源（中国用户加速）
configure_npm_registry() {
    if command -v npm >/dev/null 2>&1; then
        npm config set registry https://registry.npmmirror.com
        log_info "npm registry set to npmmirror.com"
    fi
}

# 主逻辑
main() {
    ensure_npm
    configure_npm_registry
}

main "$@"

