#!/usr/bin/env bash
# setup/npm-registry.sh - 配置 npm 镜像源
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

# 加载 nvm 环境
load_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
}

configure_registry() {
    load_nvm
    
    if ! command -v npm >/dev/null 2>&1; then
        log_warn "npm is not installed, skipping registry configuration"
        return 0
    fi
    
    npm config set registry https://registry.npmmirror.com
    log_info "npm registry set to npmmirror.com"
}

main() {
    configure_registry
}

main "$@"

