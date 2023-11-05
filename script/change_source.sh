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

# Step 1 换源
print_with_padding "Changing sources list start."
sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup
 # 获取Ubuntu版本号
ubuntu_version=$(cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2 | tr -d '"')

# 判断Ubuntu版本并执行相应的操作
if [[ "$ubuntu_version" == "22.04" ]]; then
  print_with_padding "This is ubuntu 22.04 verison"
  sudo cp ./sourcelist-for-ubuntu2204 /etc/apt/sources.list
elif  [[ "$ubuntu_version" == "20.04" ]]; then
  print_with_padding "This is ubuntu 20.04 verison"
  sudo cp ./sourcelist-for-ubuntu2004 /etc/apt/sources.list
else
  print_with_padding "!!! This Configuration is not prepared for your ubuntu version.Terminated."
  exit 1
fi
 
sudo apt -y update
sudo apt -y upgrade
# 输出成功消息
print_with_padding "Changing sources list over."

