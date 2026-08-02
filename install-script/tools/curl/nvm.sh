#!/usr/bin/env bash
# tools/curl/nvm.sh - nvm 安装脚本 (Node Version Manager)
# https://github.com/nvm-sh/nvm
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="nvm"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NVM_VERSION="v0.40.4"

is_installed() {
    [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]
}

do_install() {
    # Keep the upstream installer from appending eager nvm.sh loads to a shell
    # profile. ~/.bash-source supplies the repository's lazy integration.
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" \
        | PROFILE=/dev/null NVM_DIR="$NVM_DIR" bash

    # Load nvm for this installer process only.
    export NVM_DIR="$HOME/.nvm"
    # nvm upstream functions are not fully compatible with `set -u`.
    set +u
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # 默认跟随 Node.js LTS，而不是 Current。
    log_info "Installing latest Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
    set -u
}

ensure_shell_integration() {
    bash "$REPO_ROOT/basic/bashrc-init.sh"
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed"
        ensure_shell_integration
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install
    ensure_shell_integration
    log_info "$TOOL_NAME installed successfully"
}

main "$@"
