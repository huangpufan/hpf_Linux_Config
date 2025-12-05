#!/usr/bin/env bash
set -Eeuo pipefail

# ARCHIVED: This script is no longer maintained
# lua-language-server can now be installed via package managers or mason.nvim

TARBALL="$HOME/hpf_Linux_Config/install_package/lua-language-server-3.7.0-linux-x64.tar.gz"
INSTALL_DIR="$HOME/.local/bin/lua-language-server-folder"
BIN_LINK="$HOME/.local/bin/lua-language-server"

# Check if tarball exists
if [ ! -f "$TARBALL" ]; then
    echo "[ERROR] Tarball not found: $TARBALL"
    exit 1
fi

# Clean up old installation
rm -rf "$INSTALL_DIR" "$BIN_LINK"

# Install
mkdir -p "$INSTALL_DIR"
tar -xf "$TARBALL" -C "$INSTALL_DIR"
ln -s "$INSTALL_DIR/bin/lua-language-server" "$BIN_LINK"

echo "lua-language-server installed to $BIN_LINK"
