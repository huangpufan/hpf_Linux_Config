#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/linux-package-repository"

# Clone repository if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning linux-package-repository..."
    git clone git@github.com:huangpufan/linux-package-repository.git "$REPO_DIR" --depth=1
fi

echo "Updating linux-package-repository..."
cd "$REPO_DIR"
git pull || echo "[WARN] Failed to pull updates, continuing with existing version"

bash ./cmake-install.sh || echo "[WARN] cmake-install.sh failed"
bash ./cp-to-bin.sh || echo "[WARN] cp-to-bin.sh failed"
bash ./deb-install.sh || echo "[WARN] deb-install.sh failed"

echo "Linux repository install done."
