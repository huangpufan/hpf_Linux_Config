#!/usr/bin/env bash
# presets/dev-full.sh - 完整开发环境
# 包含：CLI 工具 + 编译器 + 调试工具 + 高级文件管理器
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

log_info "=========================================="
log_info "  Installing Full Development Environment"
log_info "=========================================="

# 先安装 CLI 工具集
log_info "Installing CLI toolset first..."
bash "$SCRIPT_DIR/dev-cli.sh"

# 编译工具
log_info "Installing build tools..."
bash "$TOOLS_DIR/apt/build-essential.sh" || true
bash "$TOOLS_DIR/apt/xmake.sh" || true

# 高级 Cargo 工具
log_info "Installing advanced Cargo tools..."
bash "$TOOLS_DIR/cargo/yazi.sh" || true
bash "$TOOLS_DIR/cargo/mprocs.sh" || true

# Pip 工具（调试相关）
log_info "Installing Pip tools..."
bash "$TOOLS_DIR/pip/pysocks.sh" || true
bash "$TOOLS_DIR/pip/gdbgui.sh" || true
bash "$TOOLS_DIR/pip/gdbfrontend.sh" || true

# 更多 Snap 工具
log_info "Installing additional Snap tools..."
bash "$TOOLS_DIR/snap/zellij.sh" || true
bash "$TOOLS_DIR/snap/lnav.sh" || true
bash "$TOOLS_DIR/snap/bandwhich.sh" || true

log_info "=========================================="
log_info "  Full Development Environment Complete!"
log_info "=========================================="

