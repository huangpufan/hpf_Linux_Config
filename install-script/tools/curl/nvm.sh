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

ensure_login_path() {
    # 让**登录 shell** 也能找到 nvm 装的 node。
    # 为什么需要：npm 全局 shim（pi/codex/gemini…）是 `#!/usr/bin/env node`，
    # 只有 shim 在 PATH 上、node 不在时会报
    # "/usr/bin/env: 'node': No such file or directory"。
    # 仓库的 .bash-source 只覆盖交互式 shell（它从 .bashrc 进来，而 .bashrc 对
    # 非交互 shell 会提前 return），所以这里补 ~/.profile（登录 shell 会读）。
    local profile="$HOME/.profile"
    local marker="# nvm node on PATH for login shells (managed by hpf_Linux_Config)"
    if [ -f "$profile" ] && grep -qF "$marker" "$profile"; then
        return 0
    fi
    cat >> "$profile" <<'EOF'

# nvm node on PATH for login shells (managed by hpf_Linux_Config)
if [ -d "$HOME/.nvm/versions/node" ]; then
    _hpf_node_bin="$(ls -d "$HOME"/.nvm/versions/node/*/bin 2>/dev/null | sort -V | tail -1)"
    if [ -n "$_hpf_node_bin" ]; then
        case ":$PATH:" in
            *":$_hpf_node_bin:"*) ;;
            *) PATH="$_hpf_node_bin:$PATH" ;;
        esac
        export PATH
    fi
    unset _hpf_node_bin
fi
EOF
    log_info "node path appended to ~/.profile (login shells)"
}

ensure_shell_integration() {
    bash "$REPO_ROOT/basic/bashrc-init.sh"
    ensure_login_path
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
