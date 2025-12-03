#!/usr/bin/env bash
set -Eeuo pipefail

# 检查 GCC 版本
if command -v gcc >/dev/null 2>&1; then
    current_gcc_version=$(gcc --version | grep '^gcc' | sed 's/^.* //g' || echo "")
    if [[ $current_gcc_version == 11.* ]]; then
        echo "GCC version 11.x is already installed: $current_gcc_version"
        exit 0
    fi
fi

echo "安装 GCC 11..."
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt-get install -y gcc-11 g++-11
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11

echo "GCC 11 安装完成！"
gcc --version | head -1
