# Set tmux configuration
ln -s ~/hpf_Linux_Config/install-script/tmux/tmux.conf ~/.tmux.conf

# Set tmux completion
sudo cp ./tmux-completion /etc/bash_completion.d/tmux-completion
source /etc/bash_completion.d/tmux-completion
