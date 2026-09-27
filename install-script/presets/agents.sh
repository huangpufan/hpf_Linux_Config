#!/usr/bin/env bash
# presets/agents.sh - Agent CLI 工具集
# 包含：pi、codex、claude、opencode、gemini、cursor-agent、devin、kimi
#
# 只安装 CLI 本体，不处理登录与凭据。
# 各 Agent 的认证方式不同，见 tools/agent/ 下各脚本头部注释。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

log_info "=========================================="
log_info "  Installing Agent CLIs"
log_info "=========================================="

# npm 类（需要 Node.js/npm；_ensure.sh 会检查并配好 npmmirror 源）
log_info "Installing npm-based agent CLIs..."
run_preset_step "pi" bash "$TOOLS_DIR/agent/pi.sh"
run_preset_step "codex" bash "$TOOLS_DIR/agent/codex.sh"
run_preset_step "claude" bash "$TOOLS_DIR/agent/claude.sh"
run_preset_step "opencode" bash "$TOOLS_DIR/agent/opencode.sh"
run_preset_step "gemini" bash "$TOOLS_DIR/agent/gemini.sh"

# curl 类（官方一键安装脚本，各自管理版本目录）
log_info "Installing curl-based agent CLIs..."
run_preset_step "cursor-agent" bash "$TOOLS_DIR/agent/cursor-agent.sh"
run_preset_step "devin" bash "$TOOLS_DIR/agent/devin.sh"
run_preset_step "kimi" bash "$TOOLS_DIR/agent/kimi.sh"

log_info "=========================================="
log_info "  Agent CLIs Installation Complete!"
log_info "=========================================="
log_info "下一步是各自登录，认证方式互不相同："
log_info "  codex        codex login --device-auth   （无头环境可用，不占用本地登录）"
log_info "  claude       配 ANTHROPIC_BASE_URL + ANTHROPIC_AUTH_TOKEN，或在 claude 内 /login"
log_info "  pi/opencode  复制 ~/.pi/agent/、~/.local/share/opencode/ 下的凭据文件"
log_info "  cursor-agent / devin / kimi / gemini  首次运行按提示登录"
finish_preset
