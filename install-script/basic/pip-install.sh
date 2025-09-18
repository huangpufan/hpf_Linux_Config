#!/bin/bash

# Define proxy functions
proxy() {
    export hostip=$(grep -oP '(?<=nameserver\ ).*' /etc/resolv.conf)
    export all_proxy="socks5://${hostip}:7890"
}

unp() {
    unset all_proxy
    unset ALL_PROXY
}

# Use python3 to check if pysocks is already installed
if python3 -c "import pysocks" >/dev/null 2>&1; then
    echo "pysocks is already installed."
else
    unp
    python3 -m pip install --user pysocks   -i https://pypi.tuna.tsinghua.edu.cn/simple
fi

# Cancel proxy
unp

# Check if gdbfrontend is already installed
if python3 -m gdbfrontend --version >/dev/null 2>&1; then
    echo "gdbfrontend is already installed."
else
    echo "Installing gdbfrontend..."
    sudo python3 -m pip install gdbfrontend  -i https://pypi.tuna.tsinghua.edu.cn/simple
fi

# Check if pipx is already installed
if command -v pipx >/dev/null 2>&1; then
    echo "pipx is already installed."
else
    echo "Installing pipx..."
    python3 -m pip install --user pipx -i https://pypi.tuna.tsinghua.edu.cn/simple
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
proxy
