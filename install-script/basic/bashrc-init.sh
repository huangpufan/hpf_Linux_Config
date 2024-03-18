#!/bin/bash
#
# Check if the Bashrc Already Set string exists in the .bashrc file
if grep -q "Bashrc Already Set" ~/.bashrc; then
    echo "Bashrc already set. Skipping script execution."
else
    # Add the bashrc-append to the end of ~/.bashrc
    ln -s ~/hpf_Linux_Config/install-script/basic/env ~/.bash-env
    ln -s ~/hpf_Linux_Config/install-script/basic/aliases ~/.bash-aliases

    cat ./bashrcappend >> ~/.bashrc
    source ~/.bashrc
    export hostip=$(cat /etc/resolv.conf | grep -oP '(?<=nameserver\ ).*')
    export all_proxy="socks5://${hostip}:7890"
fi
