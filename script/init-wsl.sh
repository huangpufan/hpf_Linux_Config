#!/bin/bash

# 变量定义区
# 脚本启动方式：sudo bash init-wsl.sh
BASHRC="/home/($whoami)/.bashrc"

 
# Step 1 换源
echo "开始换源\n\n"
sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup
 # 获取Ubuntu版本号
ubuntu_version=$(cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2 | tr -d '"')

# 判断Ubuntu版本并执行相应的操作
if [[ "$ubuntu_version" == "22.04" ]]; then
  # 如果是Ubuntu 22.04，则执行一些操作
  echo "这是Ubuntu 22.04 版本"
  content="# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse"
elif  [[ "$ubuntu_version" == "20.04" ]]; then
  echo "这是Ubuntu 20.04 版版本"
  content="
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse"
else
  echo "未识别的 ubuntu 版本号，配置终止"
  exit 1
fi
 
filename="/etc/apt/sources.list"   
# 将内容写入文件
sudo echo "$content" > "$filename"
sudo apt -y update
sudo apt -y upgrade
# 输出成功消息
echo "换源结束：$filename \n\n"
 
 
#Step 2 编辑 .bashrc 文件
echo "开始编辑 bashrc 文件 \n\n"
content=$(cat <<'EOF'
alias eb='nvim ~/.bashrc'
alias sb='source ~/.bashrc'
export hostip=\$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')
alias setss='export all_proxy=\"socks5://\${hostip}:7890\";'
alias unsetss='unset all_proxy''
EOF
) 
setss
echo -e $content >> $BASHRC
echo "bashrc 编辑结束 \n\n"
 
 
# Step 2.5 git ssh key

 
 
# Step 3 nvim 相关
sudo apt -y install -y gcc wget iputils-ping python3-pip git bear tig shellcheck ripgrep
sudo apt -y install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
sudo apt -y install ccls npm cargo xclip
sudo snap install marksman
if [[ $ubuntu_version == "22.04" ]] ; then
  sudo apt -y install efm-langserver lua5.4
fi
git clone --depth=1 https://github.com/neovim/neovim && cd neovim
make CMAKE_BUILD_TYPE=Release -j8
sudo make install
 
 
# Step 4 各类基础软件
sudo apt -y install htop
# zoxide 
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
content=$(cat <<'EOF'
eval "$(mcfly init bash)"
alias cd="z"
EOF 
) 
echo -e $content>> $BASHRC
# bat
echo "Bat install start."
cargo install --locked bat
echo "Bat install success!"
# lazygit
# cd ~/download/
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm -rf lazygit* && cd
# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install
echo -e "alias f=\"fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'\"" >> $BASHRC

# tmux
sudo apt -y install tmux
echo -e "alias a=\"tmux a -t\"" >>  ~/.bashrc

# cgdb
cd download && git clone git://github.com/cgdb/cgdb.git --depth=1 && cd cgdb
./autogen.sh
./configure
make -j
make install
cd && mkdir ~/.cgdb &&cd .cgdb


