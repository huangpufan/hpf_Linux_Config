#!/usr/bin/env bash
# setup/agent-config.sh - fetch the agent-config submodule and deploy it to $HOME
#
# agent-config 是各 AI coding agent（pi / codex / claude / devin / opencode）的配置正本，
# 作为私有 git submodule 挂在本仓库的 agent-config/ 下，不含任何密钥。
#
# 本脚本分两步：
#   1. git submodule update --init agent-config   （新 clone 里它是空目录；需要 GitHub SSH 权限）
#   2. agent-config/install.sh                    （部署到 $HOME）
#
# 第 2 步会**覆盖本机已有的 agent 配置**：
#   - ~/.pi/agent/extensions          改成指向仓库的软链（原目录先改名为 .bak.<时间戳>）
#   - ~/.claude/settings.json、~/.codex/config.toml、~/.config/devin/config.json、
#     ~/.pi/agent/{settings,trust}.json、~/.pi/agent/npm/package.json   拷贝覆盖，原文件先备份为 .bak.<时间戳>
# 含密钥的配置（pi models.json、opencode.json）永不覆盖，只提示手工填写。
#
# 建议顺序：先装 agent CLI 本体（preset agents），再跑本脚本。
# 想先看会改什么而不改任何文件：bash agent-config/install.sh --check
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="agent-config"
SUBMODULE_DIR="$(cd "$REPO_ROOT/.." && pwd)/agent-config"
INSTALLER="$SUBMODULE_DIR/install.sh"

submodule_ready() {
    [ -f "$INSTALLER" ]
}

# 已部署 = 子模块在场且 install.sh --check 退出 0（没有漂移）。--check 只读，不改任何文件；
# 非 0 是漂移或失败，两者此处都意味着“还要部署”。
is_installed() {
    submodule_ready && bash "$INSTALLER" --check >/dev/null 2>&1
}

fetch_submodule() {
    require_cmd git
    log_info "Fetching the agent-config submodule (private repo, needs GitHub SSH access)..."
    ensure_github_host_key
    if ! git -C "$(dirname "$SUBMODULE_DIR")" submodule update --init -- agent-config; then
        log_err "Could not fetch agent-config"
        log_info "Check GitHub access: ssh -T git@github.com   (preset bootstrap sets up the SSH key)"
        return 1
    fi
    if ! submodule_ready; then
        log_err "agent-config was fetched but $INSTALLER is missing"
        return 1
    fi
}

do_install() {
    submodule_ready || fetch_submodule

    log_info "Deploying agent configs to \$HOME (existing files are backed up as <file>.bak.<timestamp>)"
    local rc=0
    bash "$INSTALLER" || rc=$?
    if [ "$rc" -ne 0 ]; then
        log_err "agent-config/install.sh failed (exit $rc); files it had already replaced were backed up as <file>.bak.<timestamp>"
        return "$rc"
    fi
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already deployed and matches the repo"
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install

    if is_installed; then
        log_info "$TOOL_NAME deployed successfully"
        log_info "含密钥的配置需要手工填写：见 agent-config/README.md 的「密钥」一节"
    else
        log_err "$TOOL_NAME still differs from the repo after deploying; run: bash agent-config/install.sh --check"
        return 1
    fi
}

main "$@"
