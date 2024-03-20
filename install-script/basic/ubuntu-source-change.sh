#!/bin/bash

# Check if /etc/apt/sources.list contains "Already Done" string
if grep -q "Already Done" /etc/apt/sources.list; then
  echo "The script will not be executed as /etc/apt/sources.list contains 'Already Done'."
else
  rm -rf /etc/apt/sources.list.backup
  sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup
  
  # Get the version of Ubuntu
  ubuntu_version=$(cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2 | tr -d '"')
  
  # According to the version of Ubuntu, copy the corresponding source list to /etc/apt/sources.list
  if [[ "$ubuntu_version" == "22.04" ]]; then
      echo "This is Ubuntu 22.04 version"
      sudo cp ./source-change/source-2204  /etc/apt/sources.list
  elif [[ "$ubuntu_version" == "20.04" ]]; then
      echo "This is Ubuntu 20.04 version"
      sudo cp ./source-change/source-2004 /etc/apt/sources.list
  else
      echo "!!! This configuration is not prepared for your Ubuntu version. Terminated."
      exit 1
  fi
fi

# Check git PPA and add it if it doesn't exist
if ! grep -q "^deb .*git-core/ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    sudo add-apt-repository -y ppa:git-core/ppa
else
    echo "Git PPA已存在，无需重复添加。"
fi

# ownload the GPG key
wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/llvm-snapshot.gpg.key >/dev/null

# Add the LLVM repository if it hasn't been added already
if ! grep -q "^deb .*apt.llvm.org/focal/ llvm-toolchain-focal-14 main" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg.key] http://apt.llvm.org/focal/ llvm-toolchain-focal-14 main" | sudo tee /etc/apt/sources.list.d/llvm-toolchain-focal-14.list
else
    echo "LLVM仓库已存在，无需重复添加。"
fi

sudo apt -y update
sudo apt -y upgrade
