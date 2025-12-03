#!/usr/bin/env bash
# Quick launcher for TUI installer
# Usage: ./scripts/run.sh [options]
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Check Python version
if ! command -v python3 &>/dev/null; then
    echo "错误: 未找到 python3"
    exit 1
fi

# Check if rich is installed, install if needed
if ! python3 -c "import rich" 2>/dev/null; then
    echo "正在安装依赖..."
    pip3 install --user rich
fi

# Optional: Check sudo (recommended for installations requiring root)
if ! sudo -n true 2>/dev/null; then
    echo "提示: 建议先运行 'sudo -v' 以避免后续密码输入"
    echo "按 Enter 继续，或 Ctrl+C 取消..."
    read -r
fi

# Run installer using module syntax
exec python3 -m tui_installer "$@"
