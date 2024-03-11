wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-add-repository -y "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-13 main"
sudo apt update
sudo apt install -y clang-13 lldb-13 lld-13
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-13 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-13 100
sudo update-alternatives --install /usr/bin/cc cc /usr/bin/clang-13 100
sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-13 100
