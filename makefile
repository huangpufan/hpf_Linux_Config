# Targets: show-ssh delete-nvim link-nvim stow
show-ssh:
	cat ~/.ssh/id_ed25519.pub
delete-nvim:
	rm -f ~/.config/nvim
	rm -rf ~/.local/share/nvim
	rm -rf ~/.cache/nvim
	rm -rf ~/.local/state/nvim
link-nvim:
	ln -s ~/hpf_Linux_Config/nvim  ~/.config/nvim
# Deploy runtime configs with GNU stow
stow:
	stow home -t $(HOME)
#single_file_compile_commands_json:
