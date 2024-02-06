#!/bin/bash
#
# Add the bashrc-append to the end of ~/.bashrc
cat ./bashrc-append >> ~/.bashrc
source ~/.bashrc
export hostip=$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')
export all_proxy="socks5://${hostip}:7890";
