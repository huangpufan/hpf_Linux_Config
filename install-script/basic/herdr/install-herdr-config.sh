#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/herdr"
CONFIG_PATH="${CONFIG_DIR}/config.toml"

mkdir -p "$CONFIG_DIR"
rm -f "$CONFIG_PATH"
ln -sf "$SCRIPT_DIR/config.toml" "$CONFIG_PATH"

if command -v herdr >/dev/null 2>&1 && herdr status server >/dev/null 2>&1; then
    herdr server reload-config >/dev/null
    echo "herdr config reloaded."
fi

echo "herdr configuration installed successfully!"
