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
echo ""
echo "ADD   export PATH=\$PATH:/home/hpf/install/qemu-5.2.0/qemugiett/qemu/  to your bashrc!"
echo "And source ~/.bashrc"
rm -rf ~/download/qemu
