#!/usr/bin/env bash
set -Eeuo pipefail

directories=("project" "install" "download" "picture" "bin" "workspace" ".config" ".config/nvim")

for dir in "${directories[@]}"; do
    target_dir="$HOME/$dir"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
        echo "Created directory: $target_dir"
    else
        echo "Directory already exists: $target_dir"
    fi
done

echo "Directory structure created successfully!"
