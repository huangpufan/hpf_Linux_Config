sudo apt install -y build-essential zlib1g-dev pkg-config libglib2.0-dev  binutils-dev libboost-all-dev autoconf libtool libssl-dev libpixman-1-dev virtualenv flex bison
mkdir ~/download/qemu
wget https://download.qemu.org/qemu-5.2.0.tar.xz -P ~/download/qemu/

cd ~/download/qemu
tar -xf qemu-5.2.0.tar.xz
cd qemu-5.2.0
mkdir build 
cd build
../configure --prefix=/home/hpf/install/qemu-5.2.0/qemugiett/qemu/
make -j32
make install


# 将需要添加的路径设置为一个变量
PATH_TO_ADD='export PATH=$PATH:/home/hpf/install/qemu-5.2.0/qemugiett/qemu/bin'

# 检查 ~/.bashrc 文件中是否已包含该路径
if ! grep -qF "$PATH_TO_ADD" ~/.bashrc; then
  # 如果没有找到，添加到 ~/.bashrc 文件末尾
  echo "$PATH_TO_ADD" >> ~/.bashrc
  echo "Path has been added to ~/.bashrc"
else
  echo "Path already exists in ~/.bashrc"
fi

echo "Please source ~/.bashrc"
rm -rf ~/download/qemu
