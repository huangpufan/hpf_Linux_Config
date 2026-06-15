#!/usr/bin/env bash
# presets/dev-full.sh - 完整开发环境
# 包含：CLI 工具 + 编译器 + 调试工具 + 高级文件管理器
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

log_info "=========================================="
log_info "  Installing Full Development Environment"
log_info "=========================================="

# 先安装 CLI 工具集
log_info "Installing CLI toolset first..."
run_preset_step "preset-dev-cli" bash "$SCRIPT_DIR/dev-cli.sh"

# 编译工具
log_info "Installing build tools..."
run_preset_step "build-essential" bash "$TOOLS_DIR/apt/build-essential.sh"
run_preset_step "xmake" bash "$TOOLS_DIR/apt/xmake.sh"

# 高级 Cargo 工具
log_info "Installing advanced Cargo tools..."
run_preset_step "yazi" bash "$TOOLS_DIR/cargo/yazi.sh"
run_preset_step "mprocs" bash "$TOOLS_DIR/cargo/mprocs.sh"

# Pip 工具（调试相关）
log_info "Installing Pip tools..."
run_preset_step "pysocks" bash "$TOOLS_DIR/pip/pysocks.sh"
run_preset_step "gdbgui" bash "$TOOLS_DIR/pip/gdbgui.sh"
run_preset_step "gdbfrontend" bash "$TOOLS_DIR/pip/gdbfrontend.sh"

# 更多 Snap 工具
log_info "Installing additional Snap tools..."
run_preset_step "zellij" bash "$TOOLS_DIR/snap/zellij.sh"
run_preset_step "lnav" bash "$TOOLS_DIR/snap/lnav.sh"
run_preset_step "bandwhich" bash "$TOOLS_DIR/snap/bandwhich.sh"

log_info "=========================================="
log_info "  Full Development Environment Complete!"
log_info "=========================================="
finish_preset
