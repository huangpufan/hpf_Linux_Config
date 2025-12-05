#!/usr/bin/env bash
set -Eeuo pipefail

# Install vim with a popular configuration
if [ -d ~/.vim_runtime ]; then
    echo "Vim runtime already exists, updating..."
    cd ~/.vim_runtime && git pull
else
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
fi

sh ~/.vim_runtime/install_basic_vimrc.sh
echo "Vim configuration installed successfully!"
