#!/usr/bin/env bash
set -Eeuo pipefail

# Source bashrc if exists (for PATH and other env vars)
if [ -f ~/.bashrc ]; then
    # shellcheck source=/dev/null
    . ~/.bashrc 2>/dev/null || true
fi

# Install zoxide if not installed
if ! command -v zoxide >/dev/null 2>&1; then
    echo "zoxide not found, installing..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    echo "zoxide is already installed."
fi

# Install lazygit if not installed
if ! command -v lazygit >/dev/null 2>&1; then
    echo "lazygit not found, installing..."
    mkdir -p ~/download
    cd ~/download/
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm -rf lazygit* 
    cd ~
else
    echo "lazygit is already installed."
fi

# Install nvm if not installed (mainly used for copilot.lua Nvim plugin)
if [ ! -d "$HOME/.nvm" ]; then
    echo "nvm not found, installing..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install 18
    nvm use 18
    nvm alias default v18
else
    echo "nvm is already installed."
fi

echo "Tools installation completed!"
