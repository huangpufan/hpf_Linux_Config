# git lfs install 
# wget https://github.com/git-lfs/git-lfs/releases/download/v3.4.1/git-lfs-linux-amd64-v3.4.1.tar.gz
# tar -xf git-lfs-linux-amd64-v3.4.1.tar.gz
# cd git-lfs-3.4.1/
# sudo bash install.sh
#

# apt install
sudo apt install -y apt-utils binutils bison flex bc build-essential make mtd-utils gcc-arm-linux-gnueabi u-boot-tools python3.9 python3-pip git zip unzip curl wget gcc g++ ruby dosfstools mtools default-jre default-jdk scons python3-distutils perl openssl libssl-dev cpio git-lfs m4 ccache zlib1g-dev tar rsync liblz4-tool genext2fs binutils-dev device-tree-compiler e2fsprogs git-core gnupg gnutls-bin gperf lib32ncurses5-dev libffi-dev zlib* libelf-dev libx11-dev libgl1-mesa-dev lib32z1-dev xsltproc x11proto-core-dev libc6-dev-i386 libxml2-dev lib32z-dev libdwarf-dev 
sudo apt install -y grsync xxd libglib2.0-dev libpixman-1-dev kmod jfsutils reiserfsprogs xfsprogs squashfs-tools  pcmciautils quota ppp libtinfo-dev libtinfo5 libncurses5 libncurses5-dev libncursesw5 libstdc++6  gcc-arm-none-eabi vim ssh locales doxygen
sudo apt install -y libxinerama-dev libxcursor-dev libxrandr-dev libxi-dev
sudo apt install -y gcc-riscv64-unknown-elf
sudo apt install -y gdb-multiarch patchelf libstdc++-13-dev clangd

# pip install
cd ~/project/OpenHarmony-v4.0-Release/OpenHarmony/
python3 -m pip install --user build/hb
