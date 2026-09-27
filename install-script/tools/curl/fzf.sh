#!/usr/bin/env bash
# tools/curl/fzf.sh - fzf 安装脚本 (fuzzy finder)
# https://github.com/junegunn/fzf
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="fzf"
TOOL_CMD="fzf"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # 检查 fzf 安装脚本是否存在
    if [ -f ~/.fzf/install ]; then
        log_info "fzf directory exists, running install script"
        ~/.fzf/install --all
        return 0
    fi
    
    # 清理不完整的目录
    if [ -d ~/.fzf ]; then
        log_info "Removing incomplete fzf directory"
        rm -rf ~/.fzf
    fi
    
    # 克隆仓库
    if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; then
        ~/.fzf/install --all
    else
        log_err "Failed to clone fzf repository"
        [ -d ~/.fzf ] && rm -rf ~/.fzf
        return 1
    fi
}

ensure_login_path() {
    # fzf 的官方安装器把二进制放在 ~/.fzf/bin，并只往 ~/.bashrc 追加 PATH；
    # 而登录/非交互 shell 读不到那里（Ubuntu 的 .bashrc 对非交互 shell 提前 return）
    # —— 结果是 runner 的 check_cmd `command -v fzf` 误报失败（fzf 其实已装好）。
    # 这里补 ~/.profile（登录 shell 会读）。
    local profile="$HOME/.profile"
    local marker="# fzf bin on PATH for login shells (managed by hpf_Linux_Config)"
    if [ -f "$profile" ] && grep -qF "$marker" "$profile"; then
        return 0
    fi
    cat >> "$profile" <<'EOF'

# fzf bin on PATH for login shells (managed by hpf_Linux_Config)
if [ -d "$HOME/.fzf/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.fzf/bin:"*) ;;
        *) PATH="$HOME/.fzf/bin:$PATH" ;;
    esac
    export PATH
fi
EOF
    log_info "fzf bin appended to ~/.profile (login shells)"
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed"
        ensure_login_path
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install
    ensure_login_path
    log_info "$TOOL_NAME installed successfully"
}

main "$@"

