#!/usr/bin/env bash
set -Eeuo pipefail

DEST_DIR="$HOME/personal-config"

if [ -d "$DEST_DIR" ]; then
    echo "personal-config already exists, updating..."
    cd "$DEST_DIR" && git pull
else
    git clone git@github.com:huangpufan/personal-config.git "$DEST_DIR" --depth=1
fi

echo "personal-config installed successfully!"
