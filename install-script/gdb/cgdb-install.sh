#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check if cgdb is already installed
if command -v cgdb >/dev/null 2>&1; then
    echo "cgdb is already installed."
    exit 0
fi

# Dependencies
sudo apt install -y texinfo libreadline-dev autoconf automake libtool flex bison

# Latest version install
CGDB_DIR="$HOME/download/cgdb"
if [ -d "$CGDB_DIR" ]; then
    rm -rf "$CGDB_DIR"
fi

git clone https://github.com/cgdb/cgdb.git "$CGDB_DIR" --depth=1
cd "$CGDB_DIR"
./autogen.sh
./configure
make -j"$(nproc)"
sudo make install
rm -rf "$CGDB_DIR"

# Setup cgdb config — prefer stow-managed symlink, fall back to manual
mkdir -p "$HOME/.cgdb"
if [ ! -L "$HOME/.cgdb/cgdbrc" ] && [ ! -e "$HOME/.cgdb/cgdbrc" ]; then
    # First check if stow has already deployed it under home/
    if [ -f "$REPO_ROOT/home/.cgdb/cgdbrc" ]; then
        ln -s "$REPO_ROOT/home/.cgdb/cgdbrc" "$HOME/.cgdb/cgdbrc"
    else
        ln -s "$SCRIPT_DIR/cgdbrc" "$HOME/.cgdb/cgdbrc"
    fi
fi

echo "cgdb installed successfully!"
