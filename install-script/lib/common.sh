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

ensure_github_host_key() {
  # 让 GitHub 的 SSH 主机密钥可信，免去首次连接的 "Are you sure you want to continue
  # connecting?" 提示。agent / 无 tty 的会话回答不了它，`git clone git@github.com:...`
  # 会以 "Host key verification failed" 失败；bootstrap 只传 key，不登记主机密钥。
  # 信任锚是 HTTPS 下的 api.github.com/meta（GitHub 文档给出的主机密钥来源），不是首次
  # 连接时盲信（TOFU）。github.com:22 与 ssh.github.com:443 用同一组密钥，两个名字都登记。
  # 幂等：已有条目不动。任何一步拿不到都只告警并返回 0，由随后的 git/ssh 自己报真实错误。
  local known_hosts="$HOME/.ssh/known_hosts" target key keys
  local -a missing=()

  if ! command -v ssh-keygen >/dev/null 2>&1; then
    log_warn "ssh-keygen not found; cannot pre-trust GitHub's SSH host keys"
    return 0
  fi
  for target in github.com '[ssh.github.com]:443'; do
    if ! ssh-keygen -F "$target" -f "$known_hosts" >/dev/null 2>&1; then
      missing+=("$target")
    fi
  done
  if [ "${#missing[@]}" -eq 0 ]; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
    log_warn "curl/python3 not found; cannot pre-trust GitHub's SSH host keys"
    return 0
  fi
  # 只收严格符合 "<类型> <base64>" 的行，别的一律丢弃：不信任响应里除密钥外的任何内容。
  keys="$(curl -fsSL --max-time 20 https://api.github.com/meta 2>/dev/null | python3 -I -c '
import json, re, sys
try:
    entries = json.load(sys.stdin).get("ssh_keys", [])
except Exception:
    entries = []
for entry in entries:
    if isinstance(entry, str) and re.fullmatch(r"(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp(256|384|521)) [A-Za-z0-9+/=]+", entry):
        print(entry)
' 2>/dev/null)" || keys=""
  if [ -z "$keys" ]; then
    log_warn "could not fetch GitHub's SSH host keys (api.github.com/meta); ssh may ask to confirm the host key"
    return 0
  fi

  # 新建的 ~/.ssh 为 700、known_hosts 为 600；已存在的目录/文件权限一律不动
  [ -d "$HOME/.ssh" ] || (umask 077; mkdir -p "$HOME/.ssh")
  (umask 077; touch "$known_hosts")
  # 手改过的 known_hosts 可能没有结尾换行，直接追加会把两条记录粘成一行
  if [ -s "$known_hosts" ] && [ -n "$(tail -c1 "$known_hosts")" ]; then
    printf '\n' >> "$known_hosts"
  fi
  while IFS= read -r key; do
    for target in "${missing[@]}"; do
      printf '%s %s\n' "$target" "$key" >> "$known_hosts"
    done
  done <<< "$keys"
  log_info "Trusted GitHub SSH host keys for: ${missing[*]} (source: api.github.com/meta)"
  return 0
}
