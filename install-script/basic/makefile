SSH_KEY_PATH=~/.ssh/id_ed25519
SSH_KEY_PUB=$(SSH_KEY_PATH).pub

sshkey-generate:
	./sshkey-generate.sh

git-identity:
	../setup/git-identity.sh

github-auth:
	../setup/github-auth.sh

github-ssh:
	../setup/github-ssh.sh

sync:
	./sync.sh
