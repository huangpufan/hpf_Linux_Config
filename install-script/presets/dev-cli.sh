#!/usr/bin/env bash
# presets/dev-cli.sh - 命令行开发工具集
# 包含：现代 CLI 工具，适合日常开发使用
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

log_info "=========================================="
log_info "  Installing CLI Development Toolset"
log_info "=========================================="

# 先安装最小工具集
log_info "Installing minimal toolset first..."
bash "$SCRIPT_DIR/minimal.sh"

# APT 工具
log_info "Installing additional APT tools..."
bash "$TOOLS_DIR/apt/ranger.sh" || true
bash "$TOOLS_DIR/apt/ncdu.sh" || true
bash "$TOOLS_DIR/apt/tldr.sh" || true
bash "$TOOLS_DIR/apt/neofetch.sh" || true
bash "$TOOLS_DIR/apt/xclip.sh" || true
bash "$TOOLS_DIR/apt/silversearcher-ag.sh" || true

# Curl 工具
log_info "Installing curl-based tools..."
bash "$TOOLS_DIR/curl/lazygit.sh" || true
bash "$TOOLS_DIR/curl/nvm.sh" || true

# Cargo 工具
log_info "Installing Cargo tools..."
bash "$TOOLS_DIR/cargo/eza.sh" || true
bash "$TOOLS_DIR/cargo/broot.sh" || true
bash "$TOOLS_DIR/cargo/sd.sh" || true
bash "$TOOLS_DIR/cargo/ouch.sh" || true

# NPM 工具
log_info "Installing NPM tools..."
bash "$TOOLS_DIR/npm/fkill.sh" || true

# Snap 工具（如果可用）
log_info "Installing Snap tools..."
bash "$TOOLS_DIR/snap/btop.sh" || true
bash "$TOOLS_DIR/snap/dust.sh" || true
bash "$TOOLS_DIR/snap/procs.sh" || true

log_info "=========================================="
log_info "  CLI Development Toolset Complete!"
log_info "=========================================="

