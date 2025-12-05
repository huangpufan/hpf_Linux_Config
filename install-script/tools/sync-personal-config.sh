#!/usr/bin/env bash
set -Eeuo pipefail

echo "Start to sync personal config"

# Define directories to sync
declare -A repos=(
    ["$HOME/hpf_Linux_Config"]="hpf_Linux_Config"
    ["$HOME/hpf_Linux_Config/install-script/basic/linux-package-repository"]="linux-package-repository"
    ["$HOME/project/self-learning-project"]="self-learning-project"
)

# Sync each repository
for dir in "${!repos[@]}"; do
    name="${repos[$dir]}"
    if [ -d "$dir" ]; then
        echo "Syncing $name..."
        cd "$dir"
        git pull || echo "[WARN] Failed to pull $name"
    else
        echo "[WARN] Directory not found: $dir"
    fi
done

echo "Sync completed!"
