#!/usr/bin/env bash
# presets/dev-cli.sh - 命令行开发工具集
# 包含：现代 CLI 工具，适合日常开发使用
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

log_info "=========================================="
log_info "  Installing CLI Development Toolset"
log_info "=========================================="

# 先安装最小工具集
log_info "Installing minimal toolset first..."
run_preset_step "preset-minimal" bash "$SCRIPT_DIR/minimal.sh"

# APT 工具
log_info "Installing additional APT tools..."
run_preset_step "ranger" bash "$TOOLS_DIR/apt/ranger.sh"
run_preset_step "ncdu" bash "$TOOLS_DIR/apt/ncdu.sh"
run_preset_step "tldr" bash "$TOOLS_DIR/apt/tldr.sh"
run_preset_step "yq" bash "$TOOLS_DIR/apt/yq.sh"
run_preset_step "duf" bash "$TOOLS_DIR/apt/duf.sh"
run_preset_step "gdu" bash "$TOOLS_DIR/apt/gdu.sh"
run_preset_step "xclip" bash "$TOOLS_DIR/apt/xclip.sh"
run_preset_step "silversearcher-ag" bash "$TOOLS_DIR/apt/silversearcher-ag.sh"

# Curl 工具
log_info "Installing curl-based tools..."
run_preset_step "lazygit" bash "$TOOLS_DIR/curl/lazygit.sh"
run_preset_step "nvm" bash "$TOOLS_DIR/curl/nvm.sh"

# Cargo 工具（优先于 apt 版，获取最新版本）
log_info "Installing Cargo tools..."
run_preset_step "eza" bash "$TOOLS_DIR/cargo/eza.sh"
run_preset_step "broot" bash "$TOOLS_DIR/cargo/broot.sh"
run_preset_step "sd" bash "$TOOLS_DIR/cargo/sd.sh"
run_preset_step "ouch" bash "$TOOLS_DIR/cargo/ouch.sh"
run_preset_step "just" bash "$TOOLS_DIR/cargo/just.sh"
run_preset_step "delta" bash "$TOOLS_DIR/cargo/delta.sh"
run_preset_step "doggo" bash "$TOOLS_DIR/cargo/doggo.sh"
run_preset_step "tre" bash "$TOOLS_DIR/cargo/tre.sh"
run_preset_step "btm" bash "$TOOLS_DIR/cargo/btm.sh"
run_preset_step "fd" bash "$TOOLS_DIR/cargo/fd.sh"
run_preset_step "bat" bash "$TOOLS_DIR/cargo/bat.sh"
run_preset_step "glow" bash "$TOOLS_DIR/snap/glow.sh"
run_preset_step "tealdeer" bash "$TOOLS_DIR/cargo/tealdeer.sh"

# NPM 工具
log_info "Installing NPM tools..."
run_preset_step "fkill" bash "$TOOLS_DIR/npm/fkill.sh"

# Snap 工具（如果可用）
log_info "Installing Snap tools..."
run_preset_step "btop" bash "$TOOLS_DIR/snap/btop.sh"
run_preset_step "dust" bash "$TOOLS_DIR/snap/dust.sh"
run_preset_step "procs" bash "$TOOLS_DIR/snap/procs.sh"

log_info "=========================================="
log_info "  CLI Development Toolset Complete!"
log_info "=========================================="
finish_preset
