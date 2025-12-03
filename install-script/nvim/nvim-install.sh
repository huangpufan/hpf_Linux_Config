#!/bin/bash

# Define script directory for reliable path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enable strict error handling first
set -Eeuo pipefail

# Cause the user may not source the .bashrc file, so we need to source it manually
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

# Get Ubuntu version for conditional package installation
ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "")

# Basic dependencies install
sudo apt -y install gcc wget iputils-ping python3-pip git bear tig 
sudo apt -y install ninja-build gettext libtool libtool-bin autoconf 
sudo apt -y install automake cmake g++ pkg-config unzip curl doxygen
sudo apt -y install ccls npm cargo xclip shellcheck ripgrep
# sudo snap install marksman --classic
# sudo snap install pyright --classic
# cp ./../install_package/marksman-linux-x64 ~/.local/bin/
# sudo npm install -g vim-language-server
pip3 install --user pynvim  -i https://pypi.tuna.tsinghua.edu.cn/simple
if [[ $ubuntu_version == "22.04" ]] ; then
  sudo apt -y install efm-langserver lua5.4
fi


# Install Neovim from a prebuilt tarball to pin version
# NOTE: Update NEOVIM_VERSION to change version; keep URL schema in sync.
NEOVIM_VERSION="0.10.4"
URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz"
WORKDIR="$(mktemp -d)"
pushd "$WORKDIR" >/dev/null
curl -fL -o nvim.tar.gz "$URL"
tar -xzf nvim.tar.gz
DEST_DIR="$HOME/.local/nvim-${NEOVIM_VERSION}"
rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"
cp -a nvim-linux-x86_64/. "$DEST_DIR/"
mkdir -p "$HOME/.local/bin"
if [ -e "$HOME/.local/bin/nvim" ] || [ -L "$HOME/.local/bin/nvim" ]; then
  mv "$HOME/.local/bin/nvim" "$HOME/.local/bin/nvim.bak-$(date +%Y%m%d-%H%M%S)"
fi
ln -sfn "$DEST_DIR/bin/nvim" "$HOME/.local/bin/nvim"
popd >/dev/null
rm -rf "$WORKDIR"


# Clear the old nvim config
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim/
# Link the new nvim config
ln -s ~/hpf_Linux_Config/nvim ~/.config/nvim
# Call clipboard-prepare.sh using absolute path from script directory
if [ -x "$SCRIPT_DIR/clipboard-prepare.sh" ]; then
  "$SCRIPT_DIR/clipboard-prepare.sh"
else
  echo "Warning: clipboard-prepare.sh not found or not executable at $SCRIPT_DIR" >&2
fi
