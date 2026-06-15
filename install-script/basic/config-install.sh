#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ln -sf "$REPO_ROOT/home/.tmux.conf" "$HOME/.tmux.conf"

cd "$SCRIPT_DIR/herdr"
bash install-herdr-config.sh
