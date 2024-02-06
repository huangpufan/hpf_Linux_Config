bashrc-init:
	./bashrc-init.sh
generate-sshkey:
	./sshkey-generate.sh
cat-sshkey:
	cat ~/.ssh/id_rsa.pub
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
	make generate-sshkey
	make cat-sshkey

# Totally install.
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
