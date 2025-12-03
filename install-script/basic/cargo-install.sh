#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if cargo is installed
if ! command -v cargo >/dev/null 2>&1; then
    echo "Cargo is not installed. Installing Cargo and Rust..."
    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi

# Ensure cargo env is loaded
if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi

# Check ~/.cargo/config symlink
CONFIG_LINK="$HOME/.cargo/config"
TARGET_FILE="$SCRIPT_DIR/cargo-config"

if [ ! -L "$CONFIG_LINK" ] && [ ! -e "$CONFIG_LINK" ]; then
    if [ ! -e "$TARGET_FILE" ]; then
        echo "[WARN] Cargo config file not found: $TARGET_FILE, skipping symlink"
    else
        echo "Creating symlink for cargo config..."
        ln -s "$TARGET_FILE" "$CONFIG_LINK"
    fi
fi

# Install software by cargo
echo "Installing cargo packages..."
cargo install mprocs eza sd broot
cargo install --locked ouch
cargo install --locked yazi-fm
