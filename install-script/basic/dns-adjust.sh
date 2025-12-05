#!/usr/bin/env bash
set -Eeuo pipefail

# Modify nameserver in /etc/resolv.conf
sudo sed -i 's/^nameserver.*/nameserver 223.6.6.6/' /etc/resolv.conf

# Check if /etc/wsl.conf exists, create if not
if [ ! -f /etc/wsl.conf ]; then
    sudo touch /etc/wsl.conf
fi

# Check if /etc/wsl.conf already contains the required content
if ! grep -q "\[network\]" /etc/wsl.conf || ! grep -q "generateResolvConf = false" /etc/wsl.conf; then
    # If not, add the content
    echo -e "\n[network]\ngenerateResolvConf = false" | sudo tee -a /etc/wsl.conf >/dev/null
    echo "Added generateResolvConf = false to /etc/wsl.conf"
else
    echo "/etc/wsl.conf already contains the required content, no modification needed"
fi

echo "DNS adjustment completed!"
