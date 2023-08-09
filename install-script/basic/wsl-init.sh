#!/bin/bash

# 脚本启动方式：bash init-wsl.sh

# 变量定义区
BASHRC="/home/$(whoami)/.bashrc"
GIT_EMAIL="59730801@qq.com"
GIT_NAME="huangpufan"

# 函数定义区
print_with_padding() {
    local string="$1"
    local length=${#string}
    local padding_length=$((100 - length))

    echo
    echo -n "$string"
    for ((i=0; i<padding_length; i++)); do
        echo -n "-"
    done
    echo
}

print_with_padding "HPF WSL Ubuntu Configuration start!"

# 创建用户目录下惯用文件夹
print_with_padding "Create usual file folder"
cd ~
mkdir project install download
mkdir .config
mkdir .config/nvim
cd -

# Step 2.5 git ssh key
print_with_padding "SSH key generating start."
echo -e '\n' | ssh-keygen -t ed25519 -C $GIT_EMAIL
git config --global user.name $GIT_NAME
git config --global user.email $GIT_EMAIL

print_with_padding "SSH key has been generated." 


# Step 4 各类基础软件

# update git to latest version
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update
sudo apt-get -y install git
 

pip install pysocks

setss
sudo apt -y install htop lua5.4  gcc-multilib efm-langserver
# zoxide 
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# lazygit
print_with_padding "lazygit install start"
cd ~/download/
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm -rf lazygit* && cd

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install
print_with_padding "lazygit install over"

# tmux
print_with_padding "tmux install start"
sudo apt -y install tmux
print_with_padding "tmux install over"

# cgdb
#print_with_padding "cgdb install start"
#cd download && git clone git://github.com/cgdb/cgdb.git --depth=1 && cd cgdb
#./autogen.sh
#./configure
#make -j
#make install
#print_with_padding "cgdb install over"
#cd && mkdir ~/.cgdb &&cd .cgdb

# python
pip install pysocks

echo "id_rsa.pub:"
cat ~/.ssh/id_rsa.pub
