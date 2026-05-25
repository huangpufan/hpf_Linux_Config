#!/usr/bin/env bash
set -Eeuo pipefail

# Define script directory for reliable path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source bashrc if exists (for PATH and other env vars)
if [ -f ~/.bashrc ]; then
    # shellcheck source=/dev/null
    . ~/.bashrc 2>/dev/null || true
fi

# Get Ubuntu version for conditional package installation
ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "")

echo "Installing Neovim dependencies..."

# Basic dependencies install
sudo apt -y install gcc wget iputils-ping python3-pip git bear tig || true
sudo apt -y install ninja-build gettext libtool libtool-bin autoconf || true
sudo apt -y install automake cmake g++ pkg-config unzip curl doxygen || true
sudo apt -y install ccls npm cargo xclip shellcheck ripgrep || true
sudo apt -y install clangd efm-langserver lua5.4 shfmt pandoc python3-restructuredtext-lint python3-venv || true
sudo apt -y install python3-pynvim || true

if command -v npm >/dev/null 2>&1; then
    npm install -g neovim pyright bash-language-server@5.4.3 vscode-langservers-extracted || true
fi

install_lua_language_server() {
    local version="3.18.2"
    local install_dir="$HOME/.local/lua-language-server-$version"
    local bin_link="$HOME/.local/bin/lua-language-server"

    if command -v lua-language-server >/dev/null 2>&1 && lua-language-server --version 2>/dev/null | grep -q "$version"; then
        return 0
    fi

    local workdir
    workdir="$(mktemp -d)"
    curl -fL --retry 3 -o "$workdir/luals.tar.gz" \
        "https://github.com/LuaLS/lua-language-server/releases/download/${version}/lua-language-server-${version}-linux-x64.tar.gz" &&
        rm -rf "$install_dir" &&
        mkdir -p "$install_dir" "$HOME/.local/bin" &&
        tar -xzf "$workdir/luals.tar.gz" -C "$install_dir" &&
        ln -sfn "$install_dir/bin/lua-language-server" "$bin_link"
    rm -rf "$workdir"
}

install_marksman() {
    local version="2026-02-08"
    local bin_path="$HOME/.local/bin/marksman"

    if command -v marksman >/dev/null 2>&1 && marksman --version 2>/dev/null | grep -q "$version"; then
        return 0
    fi

    local workdir
    workdir="$(mktemp -d)"
    curl -fL --retry 3 -o "$workdir/marksman" \
        "https://github.com/artempyanykh/marksman/releases/download/${version}/marksman-linux-x64" &&
        mkdir -p "$HOME/.local/bin" &&
        install -m 0755 "$workdir/marksman" "$bin_path"
    rm -rf "$workdir"
}

install_lua_language_server || true
install_marksman || true

export PATH="$HOME/.cargo/bin:$PATH"
if command -v cargo >/dev/null 2>&1; then
    tree_sitter_ok=false
    if command -v tree-sitter >/dev/null 2>&1; then
        tree_sitter_version="$(tree-sitter --version 2>/dev/null | awk '{print $2}')"
        if [ "$(printf '%s\n%s\n' "0.26.1" "$tree_sitter_version" | sort -V | head -n 1)" = "0.26.1" ]; then
            tree_sitter_ok=true
        fi
    fi

    if [ "$tree_sitter_ok" = false ]; then
        cargo install tree-sitter-cli --version 0.26.9 --locked --registry crates-io || true
    fi
fi

# Version-specific packages
if [[ "$ubuntu_version" == "22.04" ]]; then
    sudo apt -y install efm-langserver lua5.4 || true
fi

echo ""
echo "Installing Neovim from prebuilt tarball..."

# Install Neovim from a prebuilt tarball to pin version
# NOTE: Update NEOVIM_VERSION to change version; keep URL schema in sync.
NEOVIM_VERSION="0.12.2"
URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz"
WORKDIR="$(mktemp -d)"

pushd "$WORKDIR" >/dev/null
curl -fL -o nvim.tar.gz "$URL"
tar -xzf nvim.tar.gz

DEST_DIR="$HOME/.local/nvim-${NEOVIM_VERSION}"
rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"
cp -a nvim-linux-x86_64/. "$DEST_DIR/"

mkdir -p "$HOME/.local/bin"
if [ -e "$HOME/.local/bin/nvim" ] || [ -L "$HOME/.local/bin/nvim" ]; then
    mv "$HOME/.local/bin/nvim" "$HOME/.local/bin/nvim.bak-$(date +%Y%m%d-%H%M%S)"
fi
ln -sfn "$DEST_DIR/bin/nvim" "$HOME/.local/bin/nvim"
popd >/dev/null
rm -rf "$WORKDIR"

echo ""
echo "Setting up Neovim configuration..."

# Clear the old nvim config (if it's not a symlink to our config)
if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
    rm -rf ~/.config/nvim
fi
rm -rf ~/.local/share/nvim/

# Link the new nvim config
mkdir -p ~/.config
if [ ! -L ~/.config/nvim ]; then
    ln -s ~/hpf_Linux_Config/nvim ~/.config/nvim
fi

echo ""
echo "Setting up Neovim Python provider..."
PY_PROVIDER_DIR="$HOME/.local/share/nvim/python3-provider"
if command -v python3 >/dev/null 2>&1; then
    python3 -m venv "$PY_PROVIDER_DIR" &&
        "$PY_PROVIDER_DIR/bin/python" -m pip install --upgrade pip pynvim || true
fi

# Call clipboard-prepare.sh using absolute path from script directory
if [ -x "$SCRIPT_DIR/clipboard-prepare.sh" ]; then
    "$SCRIPT_DIR/clipboard-prepare.sh"
else
    echo "[WARN] clipboard-prepare.sh not found or not executable at $SCRIPT_DIR" >&2
fi

echo ""
echo "Syncing Neovim plugins..."
NVIM_BIN="$HOME/.local/bin/nvim"
"$NVIM_BIN" --headless "+Lazy! sync" "+qa"

echo ""
echo "Refreshing Treesitter parsers..."
"$NVIM_BIN" --headless "+Lazy load nvim-treesitter" "+lua require('nvim-treesitter').update():wait(300000)" "+qa" || true

echo ""
echo "Running Neovim smoke check..."
"$NVIM_BIN" --headless "+qa"

echo ""
echo "Neovim $NEOVIM_VERSION installed successfully!"
echo "Run 'nvim' to start editing."
