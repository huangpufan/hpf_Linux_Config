install:
	./nvim-install.sh
activate-leetcode-after-launch:
	# Without ccls config, ccls will not work
	cp ./dot-ccls ~/.local/share/nvim/leetcode/.ccls
delete-nvim-config:
	rm -rf ~/.config/nvim 
	rm -rf ~/.local/share/nvim 
	rm -rf ~/.cache/nvim 
	rm -rf ~/.local/state/nvim/
backup-nvim-config:
	bash ./backup-nvim-config.sh
restore-nvim-config:
	bash ./restore-nvim-config.sh
hpf-link-nvim-config:
	make delete-nvim-config
	ln -s /home/hpf/hpf_Linux_Config/nvim/ /home/hpf/.config/nvim
