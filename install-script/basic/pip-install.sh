#!/bin/bash

# Define proxy functions
set_proxy() {
    export hostip=$(grep -oP '(?<=nameserver\ ).*' /etc/resolv.conf)
    export all_proxy="socks5://${hostip}:7890"
}

unset_proxy() {
    unset all_proxy
    unset ALL_PROXY
}

# Use python3 to check if pysocks is already installed
if python3 -c "import pysocks" >/dev/null 2>&1; then
    echo "pysocks is already installed."
else
    unset_proxy
    python3 -m pip install --user pysocks -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
fi

# Cancel proxy
unset_proxy

# Check if gdbfrontend is already installed
if python3 -m gdbfrontend --version >/dev/null 2>&1; then
    echo "gdbfrontend is already installed."
else
    echo "Installing gdbfrontend..."
    sudo python3 -m pip install gdbfrontend -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
fi

# Check if pipx is already installed
if command -v pipx >/dev/null 2>&1; then
    echo "pipx is already installed."
else
    echo "Installing pipx..."
    python3 -m pip install --user pipx -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
    sudo apt-get install python3-venv
fi

# Check if gdbgui is already installed via pipx
if pipx list | grep gdbgui >/dev/null 2>&1; then
    echo "gdbgui is already installed via pipx."
else
    echo "Installing gdbgui..."
    pipx install gdbgui --force
fi

# Enable proxy
set_proxy
