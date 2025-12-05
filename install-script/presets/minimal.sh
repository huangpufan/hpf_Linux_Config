#!/usr/bin/env bash
# presets/minimal.sh - 最小工具集
# 包含：基础命令行工具，适合快速配置新系统
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

log_info "=========================================="
log_info "  Installing Minimal Toolset"
log_info "=========================================="

# APT 工具
log_info "Installing APT tools..."
bash "$TOOLS_DIR/apt/git.sh" || true
bash "$TOOLS_DIR/apt/tmux.sh" || true
bash "$TOOLS_DIR/apt/htop.sh" || true
bash "$TOOLS_DIR/apt/bat.sh" || true

# Curl 工具
log_info "Installing curl-based tools..."
bash "$TOOLS_DIR/curl/fzf.sh" || true
bash "$TOOLS_DIR/curl/zoxide.sh" || true

log_info "=========================================="
log_info "  Minimal Toolset Installation Complete!"
log_info "=========================================="

