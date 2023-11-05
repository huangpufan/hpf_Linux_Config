push:
	chmod +777 ./*
	./push_nvim_config.sh
pull:
	chmod +777 ./*	
	./pull_nvim_config.sh
show_ssh:
	cat ~/.ssh/id_ed25519.pub
