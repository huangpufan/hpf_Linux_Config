#!/usr/bin/env bash
set -Eeuo pipefail

# Check if fzf is already installed
if command -v fzf >/dev/null 2>&1; then
  echo "fzf is already installed"
  exit 0
fi

echo "fzf is not installed, proceeding with installation"

# Check if the fzf install script exists (validates complete installation)
if [ -f ~/.fzf/install ]; then
  echo "fzf directory exists, running install script"
  ~/.fzf/install --all
  exit 0
fi

# Clone the fzf repository (remove partial directory if exists)
if [ -d ~/.fzf ]; then
  echo "Removing incomplete fzf directory"
  rm -rf ~/.fzf
fi

# Clone with error handling
if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; then
  # Run the install script (non-interactive mode)
  ~/.fzf/install --all
  echo ""
  echo "FZF 安装完成！请运行 'source ~/.bashrc' 或重新打开终端"
else
  # Clean up on failure
  echo "[ERROR] Failed to clone fzf repository"
  [ -d ~/.fzf ] && rm -rf ~/.fzf
  exit 1
fi