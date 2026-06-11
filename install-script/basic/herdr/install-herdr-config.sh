#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CONFIG_DIR="${HOME}/.config/herdr"
CONFIG_PATH="${CONFIG_DIR}/config.toml"
SOURCE_PATH="${REPO_ROOT}/home/.config/herdr/config.toml"

mkdir -p "$CONFIG_DIR"
rm -f "$CONFIG_PATH"
ln -sf "$SOURCE_PATH" "$CONFIG_PATH"

if command -v herdr >/dev/null 2>&1 && herdr status server >/dev/null 2>&1; then
    herdr server reload-config >/dev/null
    echo "herdr config reloaded."
fi

echo "herdr configuration installed successfully!"
