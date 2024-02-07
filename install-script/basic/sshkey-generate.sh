BASHRC="/home/$(whoami)/.bashrc"
GIT_EMAIL="59730801@qq.com"
GIT_NAME="huangpufan"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

# 检查 SSH 密钥是否已经存在，如果不存在则创建一个
if [ ! -f "$SSH_KEY_PATH.pub" ]; then
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -q -N ""
fi

# 配置 Git 用户名和邮箱
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# 打印换行（正确的方式）
printf "\n"
echo 'Enter: https://github.com/settings/ssh/new'
