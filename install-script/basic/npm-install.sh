#!/usr/bin/env bash
# [DEPRECATED] 此脚本已迁移到模块化结构
# 请使用:
#   - setup/npm-registry.sh      配置 npm 镜像源
#   - tools/npm/fkill.sh         安装 fkill-cli
#   - presets/dev-cli.sh         安装完整 CLI 工具集
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[INFO] 此脚本已迁移到模块化结构，调用新脚本..."

# 调用新的模块化脚本
bash "$REPO_ROOT/setup/npm-registry.sh" || true
bash "$REPO_ROOT/tools/npm/fkill.sh" || true

echo "[INFO] npm-install.sh 完成"
