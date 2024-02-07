#!/bin/bash

if ! dpkg -s ranger >/dev/null 2>&1; then
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo apt update
    sudo apt install -y git tmux htop lua5.3 gcc-multilib
    sudo apt install -y cgdb bat python-is-python3 python3-pip
    sudo apt install -y build-essential ranger

    sudo snap install btop
fi
