#!/bin/bash

# 脚本启动方式：bash init-wsl.sh

# 变量定义区
BASHRC="/home/$(whoami)/.bashrc"
GIT_EMAIL="59730801@qq.com"

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


# Step 1 换源
print_with_padding "开始换源"
sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup
 # 获取Ubuntu版本号
ubuntu_version=$(cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2 | tr -d '"')

# 判断Ubuntu版本并执行相应的操作
if [[ "$ubuntu_version" == "22.04" ]]; then
  # 如果是Ubuntu 22.04，则执行一些操作
  echo "这是 Ubuntu 22.04 版本"
  sudo cp ./sourcelist-for-ubuntu2204 /etc/apt/sources.list
elif  [[ "$ubuntu_version" == "20.04" ]]; then
  echo "这是 Ubuntu 20.04 版版本"
  sudo cp ./sourcelist-for-ubuntu2004 /etc/apt/sources.list
else
  echo "!!! 未识别的 ubuntu 版本号，配置终止"
  exit 1
fi
 
sudo apt -y update
sudo apt -y upgrade
# 输出成功消息
print_with_padding "换源结束：$filename"
 
 
#Step 2 编辑 .bashrc 文件
print_with_padding "开始编辑 bashrc 文件"
cat ./bashrc_append >> ~/.bashrc
source ~/.bashrc
setss
print_with_padding "bashrc 编辑结束"
 
 
# Step 2.5 git ssh key
print_with_padding "SSH key generating start."
echo -e '\n' | ssh-keygen -t ed25519 -C $GIT_EMAIL
print_with_padding "SSH key has been generated." 

# Step 3 nvim 相关
print_with_padding "neovim install start"
sudo apt -y install -y gcc wget iputils-ping python3-pip git bear tig shellcheck ripgrep
sudo apt -y install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
sudo apt -y install ccls npm cargo xclip
sudo snap install marksman
if [[ $ubuntu_version == "22.04" ]] ; then
  sudo apt -y install efm-langserver lua5.4
fi
git clone --depth=1 https://github.com/neovim/neovim && cd neovim
make CMAKE_BUILD_TYPE=Release -j16
sudo make install
cd ..
rm -rf ./neovim
 
 
# Step 4 各类基础软件
sudo apt -y install htop
# zoxide 
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# bat
print_with_padding "Bat install start."
cargo install --locked bat
print_with_padding "Bat install over"

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
print_with_padding "cgdb install start"
cd download && git clone git://github.com/cgdb/cgdb.git --depth=1 && cd cgdb
./autogen.sh
./configure
make -j
make install
print_with_padding "cgdb install over"
cd && mkdir ~/.cgdb &&cd .cgdb


