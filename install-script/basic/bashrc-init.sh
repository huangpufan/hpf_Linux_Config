#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BASHRC_PATH="$HOME/.bashrc"
MARKER="# Bashrc Already Set - managed by hpf_Linux_Config"

# Link bash config files to the stow-managed home/ sources.
ln -sf "$REPO_ROOT/home/.bash-env" ~/.bash-env
ln -sf "$REPO_ROOT/home/.bash-aliases" ~/.bash-aliases
ln -sf "$REPO_ROOT/home/.bash-source" ~/.bash-source

touch "$BASHRC_PATH"

# nvm's upstream installer appends these eager-load lines by default. They make
# every WSL shell source the large nvm.sh implementation before showing a
# prompt. The repository's ~/.bash-source provides a compatible lazy loader.
temp_bashrc="$(mktemp)"
trap 'rm -f "$temp_bashrc"' EXIT
awk '
    index($0, "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"") == 1 { next }
    index($0, "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"") == 1 { next }
    { print }
' "$BASHRC_PATH" > "$temp_bashrc"
if ! cmp -s "$BASHRC_PATH" "$temp_bashrc"; then
    cat "$temp_bashrc" > "$BASHRC_PATH"
fi

has_shell_source() {
    local source_file="$1"
    grep -qF ". ~/$source_file" "$BASHRC_PATH" \
        || grep -qF "source ~/$source_file" "$BASHRC_PATH" \
        || grep -qF ". \"\$HOME/$source_file\"" "$BASHRC_PATH" \
        || grep -qF "source \"\$HOME/$source_file\"" "$BASHRC_PATH"
}

if ! grep -qF "$MARKER" "$BASHRC_PATH"; then
    if has_shell_source ".bash-env" \
        && has_shell_source ".bash-aliases" \
        && has_shell_source ".bash-source"; then
        # Older repository revisions used the same source layout without a
        # stable marker. Record ownership without sourcing every file twice.
        printf '\n%s\n' "$MARKER" >> "$BASHRC_PATH"
    else
        cat >> "$BASHRC_PATH" <<'EOF'

# Bashrc Already Set - managed by hpf_Linux_Config
if [ -f "$HOME/.bash-env" ]; then
    . "$HOME/.bash-env"
fi
if [ -f "$HOME/.bash-aliases" ]; then
    . "$HOME/.bash-aliases"
fi
if [ -f "$HOME/.bash-source" ]; then
    . "$HOME/.bash-source"
fi
# End hpf_Linux_Config bashrc block
EOF
    fi
fi

echo "Bashrc configuration completed!"
echo "Please run 'source ~/.bashrc' or restart your terminal."
