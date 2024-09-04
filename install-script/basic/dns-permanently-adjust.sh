sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 223.5.5.5" > /etc/resolv.conf'

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

sudo chattr +i /etc/resolv.conf
