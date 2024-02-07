SSH_KEY_PATH=~/.ssh/id_ed25519
SSH_KEY_PUB=$(SSH_KEY_PATH).pub
hostip=$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')
setss := export all_proxy="socks5://${hostip}:7890";
bashrc-init:
	./bashrc-init.sh

generate-sshkey:
	./sshkey-generate.sh $(SSH_KEY_PATH)

cat-sshkey:
	cat $(SSH_KEY_PUB)

create-folder:
	./folder-create.sh

change-source:
	./ubuntu-source-change.sh

pip-install:
	./pip-install.sh

apt-install:
	./apt-install.sh

curl-install:
	./curl-install.sh

git-install:
	./git-install.sh

cargo-install:
	./cargo-install.sh

sshkey-genarate-and-cat: 
	generate-sshkey cat-sshkey

install-all:
	./basic-install.sh 
