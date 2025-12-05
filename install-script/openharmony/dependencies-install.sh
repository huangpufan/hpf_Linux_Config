#!/usr/bin/env bash
set -Eeuo pipefail

# OpenHarmony build dependencies installation script

# All packages to install
packages=(
    apt-utils binutils bison flex bc build-essential make mtd-utils gcc-arm-linux-gnueabi 
    u-boot-tools python3.9 python3-pip git zip unzip curl wget gcc g++ ruby dosfstools 
    mtools default-jre default-jdk scons python3-distutils perl openssl libssl-dev cpio 
    git-lfs m4 ccache zlib1g-dev tar rsync liblz4-tool genext2fs binutils-dev 
    device-tree-compiler e2fsprogs git-core gnupg gnutls-bin gperf lib32ncurses5-dev 
    libffi-dev libelf-dev libx11-dev libgl1-mesa-dev lib32z1-dev xsltproc 
    x11proto-core-dev libc6-dev-i386 libxml2-dev lib32z-dev libdwarf-dev
    grsync xxd libglib2.0-dev libpixman-1-dev kmod jfsutils reiserfsprogs xfsprogs 
    squashfs-tools pcmciautils quota ppp libtinfo-dev libtinfo5 libncurses5 
    libncurses5-dev libncursesw5 libstdc++6 gcc-arm-none-eabi vim ssh locales doxygen
    libxinerama-dev libxcursor-dev libxrandr-dev libxi-dev gcc-riscv64-unknown-elf
    gdb-multiarch patchelf libstdc++-13-dev clangd
)

# Update package lists
echo "Updating package lists..."
sudo apt update

# Create log file
LOG_FILE="$HOME/installation_errors.log"
: > "$LOG_FILE"

# Install packages
for package in "${packages[@]}"; do
    echo "Installing $package..."
    if sudo apt install -y "$package" 2>/dev/null; then
        echo "Successfully installed $package"
    else
        echo "Failed to install $package" >> "$LOG_FILE"
    fi
done

# Install OpenHarmony build tools via pip
OH_PROJECT_DIR="$HOME/project/OpenHarmony"
if [ -d "$OH_PROJECT_DIR" ] && [ -d "$OH_PROJECT_DIR/build/hb" ]; then
    echo "Installing OpenHarmony build tools..."
    cd "$OH_PROJECT_DIR"
    python3 -m pip install --user build/hb
fi

# Display installation results
echo ""
echo "Installation completed."
if [ -s "$LOG_FILE" ]; then
    echo "Some packages failed to install. Check $LOG_FILE for details."
else
    echo "All packages installed successfully!"
    rm -f "$LOG_FILE"
fi
