#!/usr/bin/env bash
set -Eeuo pipefail

log_info() { printf '[INFO] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*" >&2; }
log_err()  { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || { log_err "required command not found: $1"; exit 1; }; }

is_wsl() {
  grep -qi 'microsoft' /proc/version 2>/dev/null || false
}

ubuntu_codename() {
  . /etc/os-release 2>/dev/null || true
  printf '%s' "${VERSION_CODENAME:-}"
}

ubuntu_version_id() {
  . /etc/os-release 2>/dev/null || true
  printf '%s' "${VERSION_ID:-}"
}

__APT_UPDATED=0
apt_update_once() {
  if [ "$__APT_UPDATED" -eq 0 ]; then
    DEBIAN_FRONTEND=noninteractive sudo apt -y update || sudo apt update -y || sudo apt update || true
    __APT_UPDATED=1
  fi
}

apt_install() {
  apt_update_once
  DEBIAN_FRONTEND=noninteractive sudo apt install -y "$@"
}

add_apt_repo_once() {
  # $1: list_name (without .list)  $2: deb line  $3: keyring path(optional)
  local list_name="$1"; shift
  local deb_line="$1"; shift
  local keyring_path="${1:-}"
  local list_file="/etc/apt/sources.list.d/${list_name}.list"

  if ! grep -qsF "$deb_line" "$list_file" 2>/dev/null; then
    if [ -n "$keyring_path" ] && [ ! -f "$keyring_path" ]; then
      log_warn "keyring $keyring_path not found; proceeding without check"
    fi
    echo "$deb_line" | sudo tee "$list_file" >/dev/null
    __APT_UPDATED=0
  else
    log_info "repo exists: $list_file"
  fi
}

symlink_safe() {
  # $1 target  $2 linkname
  local target="$1" linkname="$2"
  if [ -L "$linkname" ] || [ -e "$linkname" ]; then
    return 0
  fi
  ln -s "$target" "$linkname"
}

line_in_file() {
  # $1 file  $2 literal line
  local file="$1" line="$2"
  grep -qsF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

file_append_once() {
  # $1 file  $2 marker  $3 content
  local file="$1" marker="$2" content="$3"
  if ! grep -qsF "$marker" "$file" 2>/dev/null; then
    printf '%s\n' "$content" | tee -a "$file" >/dev/null
  fi
}


