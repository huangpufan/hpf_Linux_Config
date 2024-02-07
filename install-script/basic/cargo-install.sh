#!/bin/bash

if command -v cargo &> /dev/null; then
  echo "cargo is already installed. Exiting..."
  exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
cargo install stylua
cargo install --locked bat