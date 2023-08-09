sudo apt install -y build-essential zlib1g-dev pkg-config libglib2.0-dev  binutils-dev libboost-all-dev autoconf libtool libssl-dev libpixman-1-dev virtualenv flex bison
wget https://download.qemu.org/qemu-6.2.0.tar.xz -P ~/download/qemu

# sub process.
(
cd ~/download/qemu 
tar -xf qemu-6.2.0.tar.xz
cd qemu-6.2.0
mkdir build 
cd build
../configure --prefix=/home/hpf/install/qemu-6.2.0/qemugiett/qemu/
make -j32
make install
echo "ADD   export PATH=$PATH:/home/hpf/install/qemu-6.2.0/qemugiett/qemu/  to your bashrc!"
)
