#!/usr/bin/env bash
# tools/curl/herdr.sh - Herdr 安装脚本 (terminal workspace manager for AI coding agents)
# https://herdr.dev
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="herdr"
TOOL_CMD="herdr"
BIN_NAME="herdr"
MANIFEST_URL="https://herdr.dev/latest.json"
INSTALL_DIR="${HERDR_INSTALL_DIR:-$HOME/.local/bin}"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

detect_target() {
    local os arch

    case "$(uname -s)" in
        Linux) os="linux" ;;
        Darwin) os="macos" ;;
        *) log_err "unsupported OS: $(uname -s)"; exit 1 ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *) log_err "unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    printf '%s-%s\n' "$os" "$arch"
}

read_manifest_field() {
    local target="$1" field="$2"
    python3 -c '
import json
import sys

target = sys.argv[1]
field = sys.argv[2]
data = json.load(sys.stdin)

if field == "version":
    print(data.get("version", ""))
elif field == "asset_url":
    print(data.get("assets", {}).get(target, ""))
else:
    raise SystemExit(f"unknown field: {field}")
' "$target" "$field"
}

resolve_github_asset_id() {
    local owner="$1" repo="$2" tag="$3" asset_name="$4"
    local release_json

    release_json="$(
        curl -fsSL --retry 3 --connect-timeout 10 --max-time 20 \
            "https://api.github.com/repos/${owner}/${repo}/releases/tags/${tag}"
    )"

    printf '%s\n' "$release_json" | python3 -c '
import json
import sys
from urllib.parse import unquote

asset_name = unquote(sys.argv[1])
data = json.load(sys.stdin)

for asset in data.get("assets", []):
    if asset.get("name") == asset_name:
        print(asset.get("id", ""))
        break
' "$asset_name"
}

download_github_release_asset() {
    local url="$1" output="$2"
    local owner repo tag asset_name asset_id

    if [[ ! "$url" =~ ^https://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/([^/?#]+)$ ]]; then
        return 1
    fi

    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
    tag="${BASH_REMATCH[3]}"
    asset_name="${BASH_REMATCH[4]}"

    log_info "Resolving GitHub release asset via api.github.com..."
    asset_id="$(resolve_github_asset_id "$owner" "$repo" "$tag" "$asset_name")"
    if [ -z "$asset_id" ]; then
        log_warn "GitHub API did not return asset id for $asset_name"
        return 1
    fi

    curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 10 --max-time 600 \
        -H "Accept: application/octet-stream" \
        "https://api.github.com/repos/${owner}/${repo}/releases/assets/${asset_id}" \
        -o "$output"
}

download_asset() {
    local url="$1" output="$2"

    if download_github_release_asset "$url" "$output"; then
        return 0
    fi

    log_info "Downloading release asset directly..."
    curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 10 --max-time 600 "$url" -o "$output"
}

do_install() {
    local target manifest version asset_url tmp
    target="$(detect_target)"
    log_info "Detected target: $target"

    require_cmd curl
    require_cmd python3

    log_info "Fetching latest release manifest..."
    manifest="$(
        curl -fsSL --retry 3 --connect-timeout 10 --max-time 20 "$MANIFEST_URL"
    )"
    version="$(printf '%s\n' "$manifest" | read_manifest_field "$target" version)"
    asset_url="$(printf '%s\n' "$manifest" | read_manifest_field "$target" asset_url)"

    if [ -z "$asset_url" ]; then
        log_err "release manifest does not include a binary for $target"
        exit 1
    fi

    if [ -n "$version" ]; then
        log_info "Downloading $TOOL_NAME v$version..."
    else
        log_info "Downloading latest $TOOL_NAME release..."
    fi

    tmp="$(mktemp -d)"
    trap "rm -rf '$tmp'" EXIT

    download_asset "$asset_url" "$tmp/$BIN_NAME"

    mkdir -p "$INSTALL_DIR"
    install -m 0755 "$tmp/$BIN_NAME" "$INSTALL_DIR/$BIN_NAME"
    log_info "Installed $TOOL_NAME to $INSTALL_DIR/$BIN_NAME"
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed"
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install
    log_info "$TOOL_NAME installed successfully"
}

main "$@"
