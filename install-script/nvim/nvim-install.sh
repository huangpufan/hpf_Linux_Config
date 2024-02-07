#!/bin/bash

# Basic dependencies install
sudo apt -y install -y gcc wget iputils-ping python3-pip git bear tig shellcheck ripgrep
sudo apt -y install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
sudo apt -y install ccls npm cargo xclip
# sudo snap install marksman --classic
# sudo snap install pyright --classic
# cp ./../install_package/marksman-linux-x64 ~/.local/bin/
sudo npm install -g vim-language-server
pip3 install --user pynvim
if [[ $ubuntu_version == "22.04" ]] ; then
  sudo apt -y install efm-langserver lua5.4
fi


# Latest version of neovim install
cd ~
rm -rf ./neovim
git clone --depth=1 https://github.com/neovim/neovim && cd neovim
make CMAKE_BUILD_TYPE=Release -j32
sudo make install
cd ~


# Remove the tmp folder
rm -rf ./neovim


# Clear the old nvim config
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim/


# Link the new nvim config
ln -s ~/hpf_Linux_Config/nvim ~/.config/nvim
