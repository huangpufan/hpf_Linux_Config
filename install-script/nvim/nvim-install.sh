#!/usr/bin/env bash
set -Eeuo pipefail

# Source bashrc if exists (non-fatal)
# shellcheck source=/dev/null
[ -f ~/.bashrc ] && source ~/.bashrc || true

# Get Ubuntu version
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
: # cwd restored already via pushd/popd
./clipboard-prepare.sh
