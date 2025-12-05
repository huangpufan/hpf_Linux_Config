#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create bin directory if needed
mkdir -p "$HOME/bin"

# Copy clipboard-provider
if [ -f "$SCRIPT_DIR/clipboard-provider" ]; then
    cp "$SCRIPT_DIR/clipboard-provider" "$HOME/bin/clipboard-provider"
    chmod +x "$HOME/bin/clipboard-provider"
    echo "clipboard-provider installed to ~/bin/"
else
    echo "[WARN] clipboard-provider not found at $SCRIPT_DIR/clipboard-provider"
fi
