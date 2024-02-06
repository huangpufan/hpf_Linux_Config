BASHRC="/home/$(whoami)/.bashrc"
GIT_EMAIL="59730801@qq.com"
GIT_NAME="huangpufan"
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo -e '\n' | ssh-keygen -t ed25519 -C $GIT_EMAIL
fi
git config --global user.name $GIT_NAME
git config --global user.email $GIT_EMAIL
echo '\n'
echo 'Enter: https://github.com/settings/ssh/new'
