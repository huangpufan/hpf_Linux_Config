#!/bin/bash
#
# Check if the Bashrc Already Set string exists in the .bashrc file
if grep -q "Bashrc Already Set" ~/.bashrc; then
    echo "Bashrc already set. Skipping script execution."
else
    # Add the bashrc-append to the end of ~/.bashrc
    cat ./bashrc-append >> ~/.bashrc
    source ~/.bashrc
    export hostip=$(cat /etc/resolv.conf | grep -oP '(?<=nameserver\ ).*')
    export all_proxy="socks5://${hostip}:7890"
fi
