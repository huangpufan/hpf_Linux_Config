#!/usr/bin/env bash
# presets/all-tools.sh - 安装默认全量预设链
# 包含：bootstrap + dev-full；不包含编辑器、OpenHarmony 或个人专项脚本。
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

log_info "=========================================="
log_info "  Installing All Available Tools"
log_info "=========================================="

# 先完成目录、bashrc、GitHub SSH 等个人新机前置配置。
run_preset_step "preset-bootstrap" bash "$SCRIPT_DIR/bootstrap.sh"

# 安装完整开发环境预设。
run_preset_step "preset-dev-full" bash "$SCRIPT_DIR/dev-full.sh"

log_info "=========================================="
log_info "  All Tools Installation Complete!"
log_info "=========================================="
finish_preset
