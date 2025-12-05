#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

git clone git@github.com:cgdb/cgdb.git "$CGDB_DIR" --depth=1
cd "$CGDB_DIR"
./autogen.sh
./configure
make -j"$(nproc)"
sudo make install
rm -rf "$CGDB_DIR"

# Setup cgdb config
mkdir -p "$HOME/.cgdb"
if [ ! -L "$HOME/.cgdb/cgdbrc" ] && [ ! -e "$HOME/.cgdb/cgdbrc" ]; then
    ln -s "$SCRIPT_DIR/cgdbrc" "$HOME/.cgdb/cgdbrc"
fi

echo "cgdb installed successfully!"
