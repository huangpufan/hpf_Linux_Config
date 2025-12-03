#!/usr/bin/env bash
# Quick launcher for TUI installer
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# Check Python version
if ! command -v python3 &>/dev/null; then
    echo "错误: 未找到 python3"
    exit 1
fi

# Check rich library
if ! python3 -c "import rich" 2>/dev/null; then
    echo "正在安装依赖..."
    pip3 install --user rich
fi

# Check sudo (optional but recommended)
if ! sudo -n true 2>/dev/null; then
    echo "提示: 建议先运行 'sudo -v' 以避免后续密码输入"
    echo "按 Enter 继续，或 Ctrl+C 取消..."
    read
fi

# Run installer (modularized version)
exec python3 installer_new.py "$@"

