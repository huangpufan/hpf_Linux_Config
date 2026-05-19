#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[ERROR] $0:$LINENO: $BASH_COMMAND" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

ensure_backup_once() {
    local source_file="$1"
    local backup_file="$2"

    if [ -f "$source_file" ] && [ ! -f "$backup_file" ]; then
        sudo cp "$source_file" "$backup_file"
    fi
}

has_active_deb_entries() {
    local source_file="$1"
    [ -f "$source_file" ] && grep -Eq '^[[:space:]]*deb(-src)?[[:space:]]' "$source_file"
}

configure_classic_sources() {
    local template_file="$1"
    local target_file="/etc/apt/sources.list"
    local backup_file="/etc/apt/sources.list.backup"

    ensure_backup_once "$target_file" "$backup_file"
    sudo cp "$template_file" "$target_file"
}

disable_legacy_sources_list_on_noble() {
    local legacy_file="/etc/apt/sources.list"
    local legacy_backup="/etc/apt/sources.list.legacy.backup"

    if has_active_deb_entries "$legacy_file"; then
        echo "Disabling legacy /etc/apt/sources.list entries on Ubuntu 24.04"
        ensure_backup_once "$legacy_file" "$legacy_backup"
        cat <<'EOF' | sudo tee "$legacy_file" >/dev/null
# Managed by hpf_Linux_Config on Ubuntu 24.04.
# Active Ubuntu repositories live in /etc/apt/sources.list.d/ubuntu.sources.
EOF
    fi
}

configure_noble_sources() {
    local template_file="$1"
    local target_file="/etc/apt/sources.list.d/ubuntu.sources"
    local backup_file="/etc/apt/sources.list.d/ubuntu.sources.backup"

    ensure_backup_once "$target_file" "$backup_file"
    sudo cp "$template_file" "$target_file"
    disable_legacy_sources_list_on_noble
}

ensure_git_ppa() {
    if grep -Rqs "^deb .*git-core/ppa" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
        echo "Git PPA already exists, skipping."
        return 0
    fi

    if ! command -v add-apt-repository >/dev/null 2>&1; then
        sudo apt install -y software-properties-common
    fi

    sudo add-apt-repository -y ppa:git-core/ppa || echo "[WARN] Failed to add git PPA"
}

main() {
    local ubuntu_version
    ubuntu_version="$(ubuntu_version_id)"

    case "$ubuntu_version" in
        "20.04")
            echo "Configuring Aliyun mirror for Ubuntu 20.04"
            configure_classic_sources "$SCRIPT_DIR/source-change/source-2004"
            ;;
        "22.04")
            echo "Configuring Aliyun mirror for Ubuntu 22.04"
            configure_classic_sources "$SCRIPT_DIR/source-change/source-2204"
            ;;
        "24.04")
            echo "Configuring Aliyun mirror for Ubuntu 24.04"
            configure_noble_sources "$SCRIPT_DIR/source-change/source-2404"
            ;;
        *)
            echo "[ERROR] This configuration is not prepared for your Ubuntu version ($ubuntu_version)."
            exit 1
            ;;
    esac

    sudo apt -y update
    ensure_git_ppa
    sudo apt -y update
    sudo apt -y upgrade

    echo "Source change completed successfully!"
}

main "$@"
