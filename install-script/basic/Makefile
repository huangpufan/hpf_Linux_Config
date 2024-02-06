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
	make bashrc-init
	setss
	make create-folder
	make change-source
	make pip-install
	make apt-install
	make curl-install
	make git-install
	make cargo-install

