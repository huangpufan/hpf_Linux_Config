#!/bin/bash

# 修改 /etc/resolv.conf 中的 nameserver
sudo sed -i 's/^nameserver.*/nameserver 223.6.6.6/' /etc/resolv.conf

# 检查 /etc/wsl.conf 是否存在，如果不存在则创建
if [ ! -f /etc/wsl.conf ]; then
    touch /etc/wsl.conf
fi

# 检查 /etc/wsl.conf 是否已包含所需内容
if ! grep -q "\[network\]" /etc/wsl.conf || ! grep -q "generateResolvConf = false" /etc/wsl.conf; then
    # 如果不包含，则添加内容
    sudo echo -e "\n[network]\ngenerateResolvConf = false" >> /etc/wsl.conf
    echo "已添加 generateResolvConf = false 到 /etc/wsl.conf"
else
    echo "/etc/wsl.conf 已包含所需内容，无需修改"
fi

echo "脚本执行完毕"
