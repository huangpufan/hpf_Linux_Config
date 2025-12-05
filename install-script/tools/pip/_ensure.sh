#!/usr/bin/env bash
# tools/pip/_ensure.sh - 确保 pip 环境可用
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TSINGHUA_MIRROR="-i https://pypi.tuna.tsinghua.edu.cn/simple"

ensure_pip() {
    if command -v pip3 >/dev/null 2>&1; then
        log_info "pip3 is available"
        return 0
    fi
    
    log_info "Installing pip3..."
    apt_install python3-pip
}

ensure_pipx() {
    if command -v pipx >/dev/null 2>&1; then
        log_info "pipx is available"
        return 0
    fi
    
    log_info "Installing pipx..."
    python3 -m pip install --user pipx $TSINGHUA_MIRROR
    apt_install python3-venv || true
    
    # 确保 pipx 在 PATH 中
    export PATH="$HOME/.local/bin:$PATH"
}

main() {
    ensure_pip
    ensure_pipx
}

main "$@"

