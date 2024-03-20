#!/bin/bash

sudo apt-get install -y git tmux htop lua5.3 gcc-multilib
sudo apt-get install -y bat python-is-python3 python3-pip
sudo apt-get install -y build-essential ranger xclip
sudo apt-get install -y tldr
sudo apt-get install -y cppman
sudo apt-get install -y ncdu

sudo apt-get install -y git wget rpm rpm2cpio cpio make build-essential binutils m4

# snap install
sudo snap install btop dust

sudo snap install zellij --classic
sudo snap install emacs --classic
bash ./latestgccg++-install.sh
bash ./clang13-install.sh
# Bat set.Cause 
# Check if the symlink already exists
if [ ! -L ~/.local/bin/bat ]; then
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
fi
