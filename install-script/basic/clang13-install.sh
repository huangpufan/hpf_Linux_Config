# 检查 clang-13 是否已安装
if ! dpkg -l | grep -qw clang-13; then
    # 如果 clang-13 没有被安装，执行安装流程
    # 添加 LLVM 的 GPG key
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
    # 添加 LLVM 的仓库
    sudo apt-add-repository -y "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-13 main"
    # 更新包数据库
    sudo apt update
    # 安装 clang-13, lldb-13, 和 lld-13
    sudo apt install -y clang-13 lldb-13 lld-13
    # 设置 update-alternatives
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-13 100
    sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-13 100
    sudo update-alternatives --install /usr/bin/cc cc /usr/bin/clang-13 100
    sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-13 100
else
    echo "clang-13 is already installed."
fi
