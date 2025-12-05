#!/usr/bin/env bash
set -Eeuo pipefail

# Just to accelerate the npm install process
if command -v npm >/dev/null 2>&1; then
    npm config set registry https://registry.npmmirror.com
    echo "npm registry set to npmmirror.com"
else
    echo "[WARN] npm is not installed, skipping registry configuration"
fi
