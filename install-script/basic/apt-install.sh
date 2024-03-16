#!/bin/bash

if ! dpkg -s ranger >/dev/null 2>&1; then

    sudo apt install -y git tmux htop lua5.3 gcc-multilib
    sudo apt install -y bat python-is-python3 python3-pip
    sudo apt install -y build-essential ranger xclip
    sudo apt install -y tldr
    sudo apt install -y cppman
    sudo apt install -y ncdu

    sudo apt install -y git wget rpm rpm2cpio cpio make build-essential binutils m4

    # snap install
    sudo snap install btop dust cheat
    sudo snap install emacs --classic
    bash ./latestgccg++-install.sh

    # Bat set.Cause 
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
fi
