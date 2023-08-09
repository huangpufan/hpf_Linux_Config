#!/bin/bash
# 函数定义区
print_with_padding() {
    local string="$1"
    local length=${#string}
    local padding_length=$((100 - length))

    echo
    echo -n "$string"
    for ((i=0; i<padding_length; i++)); do
        echo -n "-"
    done
    echo
}
#Step 2 编辑 .bashrc 文件
print_with_padding "开始编辑 bashrc 文件"
cat ./bashrc_append >> ~/.bashrc
source ~/.bashrc
export hostip=$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')
export all_proxy="socks5://${hostip}:7890";
print_with_padding "bashrc 编辑结束"
 
