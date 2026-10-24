#!/usr/bin/env bash
# setup/dsh-plugins.sh - fetch the private dsh-plugins collection and let it configure this machine
#
# dsh-plugins（huangpufan/dsh-plugins，私有）保存 dsh 的插件清单、自有插件源码和 profile 配置模板。
# 它自带一个会探测本机状态的 runner（scripts/agent-runner.mjs）：缺什么补什么，已就绪的不动。
#
# 本脚本只做两件事，其余全部交给那个 runner：
#   1. 取回仓库：目录不存在则 `git clone --recurse-submodules`；
#      已存在则仅在已跟踪文件无改动时 `git pull --ff-only`，否则原样保留（里面可能是未提交的开发中改动）。
#      不会对子模块执行 `git submodule update`：那会把子模块 checkout 回父仓库记录的 commit，
#      在开发机上等于把正在被 dsh 加载的插件目录回退。
#   2. 在仓库里运行 `node scripts/agent-runner.mjs apply`。
#
# apply 的退出码（由 dsh-plugins 定义）：
#   0 已就绪      1 仍有可做的事      2 需要人处理（例如缺 API key）      3 某个修复步骤失败
# 其中 2 不是安装失败：脚本按成功返回，并明确提示“需要你：见上面的输出”；其余非 0 原样透传。
#
# 前置：node（先装 nvm）、GitHub SSH 权限（preset bootstrap 会生成并上传 key，并非本脚本能代办）。
# 位置：${DSH_PLUGINS_DIR:-$HOME/project/dsh-plugins}
# 仓库地址：DSH_PLUGINS_REPO 可覆盖（默认私有 GitHub 仓库；测试或镜像时用）。
# 额外参数：DSH_PLUGINS_APPLY_ARGS 按空白拆分后原样追加给 apply，例如
#   DSH_PLUGINS_APPLY_ARGS=--include-heavy      允许下载体积很大的插件资产（dsh-legao 约 2.2 GiB）
#   DSH_PLUGINS_APPLY_ARGS=--overwrite-config   允许覆盖本机已改动的配置（覆盖前备份）
# 两者都不默认开启，由使用者明确选择。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="dsh-plugins"
REPO_URL="${DSH_PLUGINS_REPO:-git@github.com:huangpufan/dsh-plugins.git}"
TARGET_DIR="${DSH_PLUGINS_DIR:-$HOME/project/dsh-plugins}"
RUNNER="$TARGET_DIR/scripts/agent-runner.mjs"

# runner 用非交互 shell 执行本脚本，PATH 里不一定有 nvm 装的 node，甚至发行版自带的旧 node
# （例如 Ubuntu 的 node 18）排在前面：而 dsh-plugins 的 runner 要求 node >= 24.15，拿旧版本去跑只会 blocked。
# 所以有 nvm 的 node 就一律把它放到 PATH 最前（与 home/.bash-source 的做法一致，按 default 别名解析），
# 没有 nvm 才退回 PATH 上已有的 node。
# 不 source tools/agent/_ensure.sh：它被 source 时就会执行，并改写 ~/.npmrc。
ensure_node_on_path() {
    local nvm_dir="${NVM_DIR:-$HOME/.nvm}" ref="" bin=""
    if [ -r "$nvm_dir/alias/default" ]; then
        IFS= read -r ref < "$nvm_dir/alias/default" || true
    fi
    # default 可能是别名链（default -> lts/* -> v24.x），最多跟 4 层
    for _ in 1 2 3 4; do
        case "$ref" in
            v[0-9]*)
                [ -x "$nvm_dir/versions/node/$ref/bin/node" ] && bin="$nvm_dir/versions/node/$ref/bin"
                break
                ;;
            "") break ;;
            *)
                [ -r "$nvm_dir/alias/$ref" ] || break
                IFS= read -r ref < "$nvm_dir/alias/$ref" || true
                ;;
        esac
    done
    # 别名没解析出来（或指向未安装的版本）时，取已安装的最高版本
    if [ -z "$bin" ]; then
        bin="$(find "$nvm_dir/versions/node" -mindepth 2 -maxdepth 2 -name bin -type d 2>/dev/null | sort -V | tail -1)"
        [ -n "$bin" ] && [ -x "$bin/node" ] || bin=""
    fi
    if [ -n "$bin" ]; then
        case ":$PATH:" in
            ":$bin:"*) ;;                     # 已在最前
            *) export PATH="$bin:$PATH" ;;
        esac
        return 0
    fi
    command -v node >/dev/null 2>&1
}

# 目录已存在且是 git 工作树（顶层就是它自己，而不是借用了上层仓库）才算“已有 checkout”。
is_checkout() {
    [ -d "$TARGET_DIR/.git" ] || [ -f "$TARGET_DIR/.git" ]
}

# 干净 = 已跟踪文件无改动。未跟踪文件和子模块里的未跟踪文件不影响 fast-forward，故不计；
# 子模块有新提交或被改动则算不干净（说明这是一份开发中的 checkout）。
tree_is_clean() {
    [ -z "$(git -C "$TARGET_DIR" status --porcelain --untracked-files=no --ignore-submodules=untracked)" ]
}

# 只有真的要对 GitHub 走 SSH 时才去登记它的主机密钥；本地路径/其它地址不碰 known_hosts。
trust_github_if_needed() {
    case "$REPO_URL" in
        git@github.com:*|ssh://git@github.com/*) ensure_github_host_key ;;
    esac
}

fetch_repo() {
    require_cmd git
    if ! is_checkout; then
        if [ -e "$TARGET_DIR" ] && [ -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
            log_err "$TARGET_DIR exists, is not empty and is not a git checkout; refusing to clone into it"
            log_info "Move it away, or point DSH_PLUGINS_DIR at another path"
            return 1
        fi
        trust_github_if_needed
        mkdir -p "$(dirname "$TARGET_DIR")"
        log_info "Cloning $REPO_URL into $TARGET_DIR (private repo, needs GitHub SSH access)..."
        if ! git clone --recurse-submodules "$REPO_URL" "$TARGET_DIR"; then
            log_err "Could not clone $REPO_URL"
            log_info "Check GitHub access: ssh -T git@github.com   (preset bootstrap sets up the SSH key)"
            log_info "If only a submodule failed, the main repo is already in $TARGET_DIR: fix access and re-run, the runner reports submodule problems precisely"
            return 1
        fi
        return 0
    fi

    if ! tree_is_clean; then
        log_warn "$TARGET_DIR has uncommitted changes to tracked files; leaving it as it is (no pull)"
        return 0
    fi
    trust_github_if_needed
    log_info "Updating $TARGET_DIR (fast-forward only)..."
    if ! git -C "$TARGET_DIR" pull --ff-only --recurse-submodules=no; then
        log_warn "git pull --ff-only did not apply (offline, diverged, or no upstream); continuing with the current checkout"
        return 0
    fi
    local moved
    moved="$(git -C "$TARGET_DIR" submodule status 2>/dev/null | grep -c '^+' || true)"
    if [ "${moved:-0}" -gt 0 ]; then
        log_info "$moved submodule(s) are checked out at a commit other than the one this repo now records; not touched."
        log_info "To follow the recorded commits (moves them; only if they hold no unpushed work): git -C $TARGET_DIR submodule update --init --recursive"
    fi
}

run_apply() {
    if [ ! -f "$RUNNER" ]; then
        log_err "$RUNNER does not exist"
        log_err "The latest dsh-plugins has not been pushed to GitHub yet: this checkout predates its self-installing runner."
        log_info "On the machine that develops dsh-plugins: commit and push it (and its plugin submodules), then run this again."
        return 1
    fi

    local -a extra=()
    if [ -n "${DSH_PLUGINS_APPLY_ARGS:-}" ]; then
        read -r -a extra <<< "$DSH_PLUGINS_APPLY_ARGS"
    fi

    log_info "Running: node scripts/agent-runner.mjs apply ${extra[*]:-}  (in $TARGET_DIR)"
    local rc=0
    (cd "$TARGET_DIR" && node scripts/agent-runner.mjs apply ${extra[@]+"${extra[@]}"}) || rc=$?
    case "$rc" in
        0)
            log_info "$TOOL_NAME is configured"
            ;;
        2)
            log_warn "needs you: see output above"
            log_warn "dsh-plugins applied everything it could; the remaining items need a person (typically API keys)."
            ;;
        1)
            log_err "dsh-plugins apply finished with work still pending (exit 1); see output above"
            log_info "Usually a heavy download or drifted local config waiting for your OK:"
            log_info "  DSH_PLUGINS_APPLY_ARGS=--include-heavy python3 install-script/agent-runner.py install dsh-plugins"
            log_info "  (--overwrite-config replaces locally edited config; a .bak-agent backup is written first)"
            return 1
            ;;
        *)
            log_err "dsh-plugins apply exited with $rc (3 = a fix step failed); see output above"
            return "$rc"
            ;;
    esac
}

# 就绪 = runner 在场且它自己的 check 通过（退出 0）。check 只读，不改任何东西。
is_installed() {
    [ -f "$RUNNER" ] && ensure_node_on_path && node "$RUNNER" check >/dev/null 2>&1
}

do_install() {
    if ! ensure_node_on_path; then
        log_err "node is not available: the dsh-plugins runner needs it"
        log_info "Install it first: python3 install-script/agent-runner.py install nvm"
        return 1
    fi
    fetch_repo
    run_apply
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already configured on this machine"
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install
}

main "$@"
