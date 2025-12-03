#!/usr/bin/env bash
set -Eeuo pipefail

# 检查 clang-13 是否已安装
if dpkg -l | grep -qw clang-13 2>/dev/null; then
    echo "clang-13 is already installed."
    exit 0
fi

# 获取 Ubuntu 代号
CODENAME=$(lsb_release -cs 2>/dev/null || echo "focal")
echo "检测到系统代号: $CODENAME"

# 添加 LLVM 的 GPG key (使用新方式，兼容 Ubuntu 22.04+)
KEYRING_FILE="/usr/share/keyrings/llvm-archive-keyring.gpg"
if [ ! -f "$KEYRING_FILE" ]; then
    echo "添加 LLVM GPG 密钥..."
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo gpg --dearmor -o "$KEYRING_FILE"
fi

# 添加 LLVM 的仓库
LIST_FILE="/etc/apt/sources.list.d/llvm-13.list"
if [ ! -f "$LIST_FILE" ]; then
    echo "添加 LLVM 仓库..."
    echo "deb [signed-by=$KEYRING_FILE] http://apt.llvm.org/$CODENAME/ llvm-toolchain-$CODENAME-13 main" | sudo tee "$LIST_FILE" > /dev/null
fi

# 更新包数据库
sudo apt update

# 安装 clang-13, lldb-13, 和 lld-13
sudo apt install -y clang-13 lldb-13 lld-13

# 设置 update-alternatives
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-13 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-13 100
sudo update-alternatives --install /usr/bin/cc cc /usr/bin/clang-13 100
sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-13 100

echo "clang-13 安装完成！"
