#!/usr/bin/env bash
set -Eeuo pipefail

TSINGHUA_MIRROR="-i https://pypi.tuna.tsinghua.edu.cn/simple"

# Install pysocks if not already installed
if python3 -c "import socks" >/dev/null 2>&1; then
    echo "pysocks is already installed."
else
    echo "Installing pysocks..."
    python3 -m pip install --user pysocks $TSINGHUA_MIRROR
fi

# Install gdbfrontend if not already installed
if python3 -m gdbfrontend --version >/dev/null 2>&1; then
    echo "gdbfrontend is already installed."
else
    echo "Installing gdbfrontend..."
    sudo python3 -m pip install gdbfrontend $TSINGHUA_MIRROR || echo "[WARN] gdbfrontend installation failed"
fi

# Install pipx if not already installed
if command -v pipx >/dev/null 2>&1; then
    echo "pipx is already installed."
else
    echo "Installing pipx..."
    python3 -m pip install --user pipx $TSINGHUA_MIRROR
    sudo apt-get install -y python3-venv || true
fi

# Ensure pipx is in PATH
export PATH="$HOME/.local/bin:$PATH"

# Install gdbgui via pipx if not already installed
if pipx list 2>/dev/null | grep -q gdbgui; then
    echo "gdbgui is already installed via pipx."
else
    echo "Installing gdbgui..."
    pipx install gdbgui --force || echo "[WARN] gdbgui installation failed"
fi

echo "Python tools installation completed!"
