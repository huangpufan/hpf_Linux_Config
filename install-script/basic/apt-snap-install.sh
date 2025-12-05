#!/usr/bin/env bash
# [DEPRECATED] 此脚本已迁移到模块化结构
# 请使用:
#   - tools/apt/*.sh             各个 APT 工具
#   - tools/snap/*.sh            各个 Snap 工具
#   - presets/minimal.sh         最小工具集
#   - presets/dev-cli.sh         CLI 开发工具集
#   - presets/dev-full.sh        完整开发环境
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APT_DIR="$REPO_ROOT/tools/apt"
SNAP_DIR="$REPO_ROOT/tools/snap"

echo "[INFO] 此脚本已迁移到模块化结构，调用新脚本..."

echo "========================================"
echo "  安装 APT 工具"
echo "========================================"

bash "$APT_DIR/git.sh" || true
bash "$APT_DIR/tmux.sh" || true
bash "$APT_DIR/htop.sh" || true
bash "$APT_DIR/bat.sh" || true
bash "$APT_DIR/ranger.sh" || true
bash "$APT_DIR/ncdu.sh" || true
bash "$APT_DIR/tldr.sh" || true
bash "$APT_DIR/neofetch.sh" || true
bash "$APT_DIR/xclip.sh" || true
bash "$APT_DIR/silversearcher-ag.sh" || true
bash "$APT_DIR/build-essential.sh" || true
bash "$APT_DIR/xmake.sh" || true

echo ""
echo "========================================"
echo "  安装 Snap 工具"
echo "========================================"

bash "$SNAP_DIR/btop.sh" || true
bash "$SNAP_DIR/dust.sh" || true
bash "$SNAP_DIR/procs.sh" || true
bash "$SNAP_DIR/bandwhich.sh" || true
bash "$SNAP_DIR/lnav.sh" || true
bash "$SNAP_DIR/zellij.sh" || true

echo ""
echo "========================================"
echo "  安装 GCC 和 Clang"
echo "========================================"

cd "$SCRIPT_DIR"
bash ./latestgccg++-install.sh || echo "[WARN] GCC 安装失败"
bash ./clang13-install.sh || echo "[WARN] Clang 安装失败"

echo ""
echo "========================================"
echo "  apt-snap-install.sh 完成！"
echo "========================================"
