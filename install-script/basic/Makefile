SSH_KEY_PATH=~/.ssh/id_ed25519
SSH_KEY_PUB=$(SSH_KEY_PATH).pub

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

sshkey-genarate-and-cat: generate-sshkey cat-sshkey

install-all:
	make bashrc-init -i
	export all_proxy="socks5://${hostip}:7890" && \
	make create-folder -i && \
	make change-source -i && \
	make pip-install -i && \
	make apt-install -i && \
	make curl-install -i && \
	make git-install -i && \
	make cargo-install -i
