#!/bin/bash

# Check if /etc/apt/sources.list contains "Already Done" string
if grep -q "Already Done" /etc/apt/sources.list; then
    echo "The script will not be executed as /etc/apt/sources.list contains 'Already Done' string."
    exit 0
fi

sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup

# Get the version of Ubuntu
ubuntu_version=$(cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2 | tr -d '"')

# According to the version of Ubuntu, copy the corresponding source list to /etc/apt/sources.list
if [[ "$ubuntu_version" == "22.04" ]]; then
    print_with_padding "This is Ubuntu 22.04 version"
    sudo cp ./source-2204  /etc/apt/sources.list
elif [[ "$ubuntu_version" == "20.04" ]]; then
    print_with_padding "This is Ubuntu 20.04 version"
    sudo cp ./source-2004 /etc/apt/sources.list
else
    print_with_padding "!!! This configuration is not prepared for your Ubuntu version. Terminated."
    exit 1
fi

# Update the source list
sudo apt -y update
sudo apt -y upgrade
