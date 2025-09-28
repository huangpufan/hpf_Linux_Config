#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[ERROR] $0:$LINENO: $BASH_COMMAND" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$REPO_ROOT/lib/common.sh"

# 不在此处强制设置代理，统一由后续 T4 策略处理

bash "$SCRIPT_DIR/bashrc-init.sh"
bash "$SCRIPT_DIR/profile-set.sh"
bash "$SCRIPT_DIR/folder-create.sh"
bash "$SCRIPT_DIR/ubuntu-source-change.sh"
bash "$SCRIPT_DIR/apt-snap-install.sh"
bash "$SCRIPT_DIR/pip-install.sh"
bash "$SCRIPT_DIR/git-install.sh"
bash "$SCRIPT_DIR/npm-install.sh"
bash "$SCRIPT_DIR/hosts-adjust.sh"
bash "$SCRIPT_DIR/dns-permanently-adjust.sh"
bash "$SCRIPT_DIR/config-install.sh"
bash "$SCRIPT_DIR/curl-install.sh"
bash "$SCRIPT_DIR/cargo-install.sh"
bash "$SCRIPT_DIR/linux-repository-install.sh"
