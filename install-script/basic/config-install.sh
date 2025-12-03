#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR/tmux"
bash install-tmux-config.sh

cd "$SCRIPT_DIR/neofetch"
bash neofetch-cfg-install.sh
