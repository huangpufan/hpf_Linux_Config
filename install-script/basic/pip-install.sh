#!/bin/bash

# Check if pysocks is already installed
if python -c "import pysocks" >/dev/null 2>&1; then
    echo "pysocks is already installed."
else
    
    # Cansel proxy
    unsetss
    # Install pysocks
    pip install pysocks -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
    pip3 install --user ueberzug -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
    # Install gbdfronted
    sudo python3 -m pip install gdbfrontend -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
    # Install gdbgui
    python3 -m pip install --user pipx -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
    sudo apt install python3.8-venv
    pipx install gdbgui --force
    # Open proxy
    setss

fi
