#!/usr/bin/env bash
# [DEPRECATED] 此脚本已迁移到模块化结构
# 请使用:
#   - tools/pip/_ensure.sh       确保 pip/pipx 环境
#   - tools/pip/pysocks.sh       安装 pysocks
#   - tools/pip/gdbfrontend.sh   安装 gdbfrontend
#   - tools/pip/gdbgui.sh        安装 gdbgui
#   - presets/dev-full.sh        安装完整开发环境
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TOOLS_DIR="$REPO_ROOT/tools/pip"

echo "[INFO] 此脚本已迁移到模块化结构，调用新脚本..."

# 调用新的模块化脚本
bash "$TOOLS_DIR/pysocks.sh" || true
bash "$TOOLS_DIR/gdbfrontend.sh" || true
bash "$TOOLS_DIR/gdbgui.sh" || true

echo "[INFO] pip-install.sh 完成"
