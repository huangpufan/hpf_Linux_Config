#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if /etc/apt/sources.list contains "Already Done" string
if grep -q "Already Done" /etc/apt/sources.list 2>/dev/null; then
    echo "The script will not be executed as /etc/apt/sources.list contains 'Already Done'."
    exit 0
fi

# Backup existing sources.list
sudo rm -rf /etc/apt/sources.list.backup
sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup

# Get the version of Ubuntu
ubuntu_version=$(grep VERSION_ID /etc/os-release | cut -d '=' -f 2 | tr -d '"')

# According to the version of Ubuntu, copy the corresponding source list
case "$ubuntu_version" in
    "22.04")
        echo "This is Ubuntu 22.04 version"
        sudo cp "$SCRIPT_DIR/source-change/source-2204" /etc/apt/sources.list
        ;;
    "20.04")
        echo "This is Ubuntu 20.04 version"
        sudo cp "$SCRIPT_DIR/source-change/source-2004" /etc/apt/sources.list
        ;;
    "24.04")
        echo "This is Ubuntu 24.04 version"
        if [ -f "$SCRIPT_DIR/source-change/source-2404" ]; then
            sudo cp "$SCRIPT_DIR/source-change/source-2404" /etc/apt/sources.list
        else
            echo "[WARN] No source file for Ubuntu 24.04, restoring backup"
            sudo mv /etc/apt/sources.list.backup /etc/apt/sources.list
            exit 1
        fi
        ;;
    *)
        echo "[ERROR] This configuration is not prepared for your Ubuntu version ($ubuntu_version)."
        sudo mv /etc/apt/sources.list.backup /etc/apt/sources.list
        exit 1
        ;;
esac

# Check git PPA and add it if it doesn't exist
if ! grep -q "^deb .*git-core/ppa" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    sudo add-apt-repository -y ppa:git-core/ppa || echo "[WARN] Failed to add git PPA"
else
    echo "Git PPA already exists, skipping."
fi

# Download the GPG key for LLVM
if [ ! -f /usr/share/keyrings/llvm-snapshot.gpg.key ]; then
    wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/llvm-snapshot.gpg.key >/dev/null
fi

# Add the LLVM repository if it hasn't been added already
if ! grep -q "^deb .*apt.llvm.org" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    # Use focal for Ubuntu 20.04, jammy for 22.04
    codename=$(lsb_release -cs)
    echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg.key] http://apt.llvm.org/$codename/ llvm-toolchain-$codename-14 main" | sudo tee /etc/apt/sources.list.d/llvm-toolchain.list
else
    echo "LLVM repository already exists, skipping."
fi

sudo apt -y update
sudo apt -y upgrade

echo "Source change completed successfully!"
