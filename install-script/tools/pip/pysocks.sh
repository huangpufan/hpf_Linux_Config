#!/usr/bin/env bash
# tools/pip/pysocks.sh - pysocks 安装脚本 (SOCKS proxy support)
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="pysocks"
TSINGHUA_MIRROR="-i https://pypi.tuna.tsinghua.edu.cn/simple"

is_installed() {
    python3 -c "import socks" >/dev/null 2>&1
}

do_install() {
    python3 -m pip install --user pysocks $TSINGHUA_MIRROR
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed"
        return 0
    fi
    
    log_info "Installing $TOOL_NAME..."
    do_install
    log_info "$TOOL_NAME installed successfully"
}

main "$@"

