#!/usr/bin/env bash
set -Eeuo pipefail

# Find all .c and .h files in the current directory and its subdirectories
# and format them in-place using clang-format.

if ! command -v clang-format >/dev/null 2>&1; then
    echo "[ERROR] clang-format is not installed."
    exit 1
fi

echo "Formatting C/C++ files..."
find . -iname '*.c' -o -iname '*.h' | xargs clang-format -i -style=file

echo "Formatting completed!"
