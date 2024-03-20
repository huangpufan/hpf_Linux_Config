# Check if fzf is already installed
if command -v fzf >/dev/null 2>&1; then
  echo "fzf is already installed"
else
  echo "fzf is not installed, proceeding with installation"
  # Clone the fzf repository into the home directory
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  # Run the install script
  ~/.fzf/install
fi
