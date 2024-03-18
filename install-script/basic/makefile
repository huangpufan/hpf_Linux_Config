SSH_KEY_PATH=~/.ssh/id_ed25519
SSH_KEY_PUB=$(SSH_KEY_PATH).pub

# generate-sshkey:
# 	./sshkey-generate.sh $(SSH_KEY_PATH)
# cat-sshkey:
# 	cat $(SSH_KEY_PUB)
first-sshkey-genarate-and-cat: 
	./sshkey-generate.sh $(SSH_KEY_PATH)
	cat $(SSH_KEY_PUB)

second-install-after-sshkey-genarate:
	./install-after-sshkey.sh
