#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检测 snap 是否可用
has_snap() {
    command -v snap >/dev/null 2>&1 && \
    (systemctl is-active snapd >/dev/null 2>&1 || snap version >/dev/null 2>&1)
}

echo "========================================"
echo "  安装基础 APT 包"
echo "========================================"

sudo add-apt-repository -y ppa:xmake-io/xmake || echo "[WARN] 无法添加 xmake PPA"

sudo apt update

# 基础工具
sudo apt-get install -y git tmux htop lua5.3 gcc-multilib || true
sudo apt-get install -y bat python-is-python3 python3-pip || true
sudo apt-get install -y build-essential ranger xclip || true
sudo apt-get install -y tldr cppman ncdu silversearcher-ag neofetch || true
sudo apt-get install -y git wget rpm rpm2cpio cpio make binutils m4 || true
sudo apt install -y xmake || echo "[WARN] xmake 安装失败"

echo ""
echo "========================================"
echo "  安装 Snap 包"
echo "========================================"

if has_snap; then
    echo "Snap 可用，安装 snap 包..."
    sudo snap install btop dust procs bandwhich lnav || true
    sudo snap install zellij --classic || true
    sudo snap install emacs --classic || true
else
    echo "[WARN] Snap 不可用（可能在容器或 WSL 中），跳过 snap 包安装"
    echo "       可以稍后手动安装: btop, dust, procs, bandwhich, lnav, zellij, emacs"
fi

echo ""
echo "========================================"
echo "  安装 GCC 和 Clang"
echo "========================================"

cd "$SCRIPT_DIR"
bash ./latestgccg++-install.sh || echo "[WARN] GCC 安装失败"
bash ./clang13-install.sh || echo "[WARN] Clang 安装失败"

echo ""
echo "========================================"
echo "  配置 bat 符号链接"
echo "========================================"

# bat 在 Ubuntu 中包名为 batcat，创建符号链接
if command -v batcat >/dev/null 2>&1 && [ ! -L ~/.local/bin/bat ]; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat
    echo "已创建 bat -> batcat 符号链接"
fi

echo ""
echo "========================================"
echo "  安装完成！"
echo "========================================"
