#!/bin/sh

# Check if cargo is installed
if ! command -v cargo >/dev/null 2>&1; then
    echo "Cargo is not installed. Installing Cargo and Rust..."
    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
fi

# Check ~/.cargo/config symlink
CONFIG_LINK="$HOME/.cargo/config"
TARGET_LINK="$HOME/hpf_Linux_Config/install-script/basic/cargo-config"

if [ ! -L "$CONFIG_LINK" ]; then
    if [ ! -e "$TARGET_LINK" ]; then
        echo "Target for symlink does not exist: $TARGET_LINK"
        exit 1
    fi
    echo "Creating symlink for cargo config..."
    ln -s "$TARGET_LINK" "$CONFIG_LINK"
fi

# Install software by cargo
echo "Installing cargo packages..."
cargo install mprocs eza sd broot
cargo install --locked ouch
cargo install --locked yazi-fm
