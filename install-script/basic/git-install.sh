# Check if fzf is installed and install it if it is not
if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found, installing..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    yes | ~/.fzf/install
else
    echo "fzf is already installed."
fi
