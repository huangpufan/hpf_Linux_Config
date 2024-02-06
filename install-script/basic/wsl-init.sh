#!/bin/bash

# 脚本启动方式：bash init-wsl.sh

# 变量定义区
BASHRC="/home/$(whoami)/.bashrc"
GIT_EMAIL="59730801@qq.com"
GIT_NAME="huangpufan"

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



# cgdb
#print_with_padding "cgdb install start"
#cd download && git clone git://github.com/cgdb/cgdb.git --depth=1 && cd cgdb
#./autogen.sh
#./configure
#make -j
#make install
#print_with_padding "cgdb install over"
#cd && mkdir ~/.cgdb &&cd .cgdb

# python

echo "id_rsa.pub:"
cat ~/.ssh/id_rsa.pub
