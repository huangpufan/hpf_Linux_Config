#!/usr/bin/env bash
# presets/all-tools.sh - 安装所有工具
# 包含：所有可用工具
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

log_info "=========================================="
log_info "  Installing All Available Tools"
log_info "=========================================="

# 先完成目录、bashrc、GitHub SSH 等前置配置，避免后续 GitHub 下载走 HTTPS 卡住。
bash "$SCRIPT_DIR/bootstrap.sh"

# 安装完整开发环境（包含大部分工具）
bash "$SCRIPT_DIR/dev-full.sh"

log_info "=========================================="
log_info "  All Tools Installation Complete!"
log_info "=========================================="
