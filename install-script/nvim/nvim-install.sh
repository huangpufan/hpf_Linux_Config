#!/bin/bash

# Cause the user may not source the .bashrc file, so we need to source it manually
source ~/.bashrc
setss
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


# Latest version of neovim install
rm -rf ~/download/neovim
git clone --depth=1 https://github.com/neovim/neovim ~/download/neovim 
cd ~/download/neovim
make CMAKE_BUILD_TYPE=Release -j32
sudo make install
# Remove the tmp folder
rm -rf ~/download/neovim


# Clear the old nvim config
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim/
# Link the new nvim config
ln -s ~/hpf_Linux_Config/nvim ~/.config/nvim
cd -
./clipboard-prepare.sh
