BASHRC="/home/$(whoami)/.bashrc"
GIT_EMAIL="59730801@qq.com"
GIT_NAME="huangpufan"

echo -e '\n' | ssh-keygen -t ed25519 -C $GIT_EMAIL
git config --global user.name $GIT_NAME
git config --global user.email $GIT_EMAIL
