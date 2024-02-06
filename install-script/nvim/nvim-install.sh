#!/bin/bash
# Step 3 nvim 相关
print_with_padding "neovim install start"
sudo apt -y install -y gcc wget iputils-ping python3-pip git bear tig shellcheck ripgrep
sudo apt -y install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
sudo apt -y install ccls npm cargo xclip
sudo snap install marksman --classic
sudo snap install pyright --classic
cp ./../install_package/marksman-linux-x64 ~/.local/bin/
sudo npm install -g vim-language-server

if [[ $ubuntu_version == "22.04" ]] ; then
  sudo apt -y install efm-langserver lua5.4
fi
rm -rf ./neovim
git clone --depth=1 https://github.com/neovim/neovim && cd neovim
make CMAKE_BUILD_TYPE=Release -j16
sudo make install
cd ..
rm -rf ./neovim

rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim/

ln -s ~/hpf_Linux_Config/nvim ~/.config/nvim
