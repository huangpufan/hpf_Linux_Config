# Check if zoxide is installed and install it if it is not
if ! command -v zoxide >/dev/null 2>&1; then
    echo "zoxide not found, installing..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    echo "zoxide is already installed."
fi

# Check if lazygit is installed and install it if it is not
if ! command -v lazygit >/dev/null 2>&1; then
    echo "lazygit not found, installing..."
    mkdir -p ~/download && cd ~/download/
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm -rf lazygit* && cd
else
    echo "lazygit is already installed."
fi

# Check if nvm is installed and install it if it is not
# Mainly used for copilot.lua(Nvim plugin)
if ! command -v nvm >/dev/null 2>&1; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    nvm install 18.0.0
    nvm use 18.0.0
else
    echo "nvm is already installed."
fi
