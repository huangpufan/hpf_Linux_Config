#!/usr/bin/env bash
set -Eeuo pipefail

# Check if fzf is already installed
if command -v fzf >/dev/null 2>&1; then
  echo "fzf is already installed: $(fzf --version)"
  exit 0
fi

echo "fzf is not installed, proceeding with installation"

# Clone the fzf repository into the home directory
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi

# Run the install script (non-interactive mode)
~/.fzf/install --all

echo ""
echo "FZF 安装完成！请运行 'source ~/.bashrc' 或重新打开终端"
