#!/bin/bash

# Define the path of the VPN subscription file
VPN_FILE_PATH="../../../personal/personal-config/env"
ENV_FILE_PATH="../../../personal/personal-config/vpn"

# Copy and unzip the clash for linux package
cp ../linux-package-repository/clash-for-linux-master.zip .
unzip clash-for-linux-master.zip
cd clash-for-linux-master

# Check if the vpn subscription file exists
if [[ -f "$VPN_FILE_PATH" ]]; then
    echo "VPN subscription file found. Using the file content as the subscription link."
    vpn_subscription_link=$(<"$VPN_FILE_PATH")
    rm -rf ./env
    mv $ENV_FILE_PATH ./env
else
    echo "VPN subscription file not found. Please enter your vpn subscription link."
    # Prompt the user to enter their vpn subscription link
    read -p "Please enter your vpn subscription link: " vpn_subscription_link
    sed -i "s|export CLASH_URL='.*'|export CLASH_URL='$vpn_subscription_link'|g" .env
fi

# Echo the subscription link (for debugging purposes)
echo "VPN Subscription Link: $vpn_subscription_link"

# Start the VPN service
sudo bash ./start.sh
