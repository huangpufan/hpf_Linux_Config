#!/usr/bin/env bash
# [DEPRECATED] 此脚本已迁移到模块化结构
# 请使用:
#   - tools/curl/zoxide.sh       安装 zoxide
#   - tools/curl/lazygit.sh      安装 lazygit
#   - tools/curl/nvm.sh          安装 nvm
#   - tools/curl/fzf.sh          安装 fzf
#   - presets/dev-cli.sh         安装完整 CLI 工具集
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TOOLS_DIR="$REPO_ROOT/tools/curl"

echo "[INFO] 此脚本已迁移到模块化结构，调用新脚本..."

# 调用新的模块化脚本
bash "$TOOLS_DIR/zoxide.sh" || true
bash "$TOOLS_DIR/lazygit.sh" || true
bash "$TOOLS_DIR/nvm.sh" || true

echo "[INFO] curl-install.sh 完成"
