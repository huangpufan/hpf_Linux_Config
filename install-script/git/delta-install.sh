#!/usr/bin/env bash
set -Eeuo pipefail

# Check if delta is already installed
if command -v delta >/dev/null 2>&1; then
    echo "delta is already installed."
    exit 0
fi

# Check if cargo is available
if ! command -v cargo >/dev/null 2>&1; then
    echo "[ERROR] cargo is not installed. Please install Rust first."
    exit 1
fi

# Ensure cargo env is loaded
if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi

echo "Installing delta via cargo..."
cargo install git-delta

echo "delta installed successfully!"
