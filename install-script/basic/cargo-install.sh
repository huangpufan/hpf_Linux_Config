#!/usr/bin/env bash
# [DEPRECATED] 此脚本已迁移到模块化结构
# 请使用:
#   - tools/cargo/_ensure.sh     确保 cargo 环境
#   - tools/cargo/eza.sh         安装 eza
#   - tools/cargo/yazi.sh        安装 yazi
#   - tools/cargo/broot.sh       安装 broot
#   - tools/cargo/mprocs.sh      安装 mprocs
#   - tools/cargo/sd.sh          安装 sd
#   - tools/cargo/ouch.sh        安装 ouch
#   - presets/dev-cli.sh         安装完整 CLI 工具集
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TOOLS_DIR="$REPO_ROOT/tools/cargo"

echo "[INFO] 此脚本已迁移到模块化结构，调用新脚本..."

# 调用新的模块化脚本
bash "$TOOLS_DIR/_ensure.sh" || true
bash "$TOOLS_DIR/eza.sh" || true
bash "$TOOLS_DIR/broot.sh" || true
bash "$TOOLS_DIR/mprocs.sh" || true
bash "$TOOLS_DIR/sd.sh" || true
bash "$TOOLS_DIR/ouch.sh" || true
bash "$TOOLS_DIR/yazi.sh" || true

echo "[INFO] cargo-install.sh 完成"
