#!/usr/bin/env bash
set -Eeuo pipefail
mkdir ~/download/qemu
wget https://download.qemu.org/qemu-6.2.0.tar.xz -P ~/download/qemu

cd ~/download/qemu 
tar -xf qemu-6.2.0.tar.xz
cd qemu-6.2.0
mkdir build 
cd build
../configure --prefix=/home/hpf/install/qemu-6.2.0/qemugiett/qemu/
make -j32
make install
echo "ADD   export PATH=$PATH:/home/hpf/install/qemu-6.2.0/qemugiett/qemu/  to your bashrc!"
rm -rf ~/download/qemu
