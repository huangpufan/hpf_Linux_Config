#!/usr/bin/env bash
# presets/minimal.sh - 最小工具集
# 包含：基础命令行工具，适合快速配置新系统
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

log_info "=========================================="
log_info "  Installing Minimal Toolset"
log_info "=========================================="

# APT 工具
log_info "Installing APT tools..."
run_preset_step "git" bash "$TOOLS_DIR/apt/git.sh"
run_preset_step "gh" bash "$TOOLS_DIR/apt/gh.sh"
run_preset_step "tmux" bash "$TOOLS_DIR/apt/tmux.sh"
run_preset_step "htop" bash "$TOOLS_DIR/apt/htop.sh"
# bat 使用 cargo 安装最新版
run_preset_step "bat" bash "$TOOLS_DIR/cargo/bat.sh"

# Curl 工具
log_info "Installing curl-based tools..."
run_preset_step "fzf" bash "$TOOLS_DIR/curl/fzf.sh"
run_preset_step "zoxide" bash "$TOOLS_DIR/curl/zoxide.sh"

log_info "=========================================="
log_info "  Minimal Toolset Installation Complete!"
log_info "=========================================="
finish_preset
