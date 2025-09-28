#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[ERROR] $0:$LINENO: $BASH_COMMAND" >&2' ERR

# Usage:
#   run.sh [jammy|focal|IMAGE[:TAG]] [COMMAND]
# Examples:
#   run.sh jammy
#   run.sh focal 'cat /etc/os-release'
#   run.sh ubuntu:24.04 'echo hello'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

IMAGE_INPUT="${1:-jammy}"
CMD_TO_RUN="${2:-}"

resolve_image() {
  case "$IMAGE_INPUT" in
    jammy) echo "ubuntu:22.04";;
    focal) echo "ubuntu:20.04";;
    *) echo "$IMAGE_INPUT";;
  esac
}

IMAGE="$(resolve_image)"

runtime() {
  if command -v docker >/dev/null 2>&1; then
    echo docker
  elif command -v podman >/dev/null 2>&1; then
    echo podman
  else
    echo "[FATAL] neither docker nor podman found" >&2
    exit 1
  fi
}

RUNTIME="$(runtime)"

# Mount repo read-only to /mnt/ws, then copy into /root/ws (writable)
MNT_RO="/mnt/ws"
WORKDIR_IN="/root/ws"

RUN_BASE=(
  "$RUNTIME" run --rm -it
  -v "$REPO_ROOT:$MNT_RO:ro"
  -w /root
  "$IMAGE"
  bash -lc
)

prepare_and_exec() {
  cat <<'EOSCRIPT'
set -Eeuo pipefail
mkdir -p /root/ws
cp -a /mnt/ws/. /root/ws/

# detect package manager and install minimal deps
if command -v apt >/dev/null 2>&1; then
  apt update -y || apt update
  DEBIAN_FRONTEND=noninteractive apt install -y sudo git make curl ca-certificates xz-utils || true
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y git make curl ca-certificates xz || true
elif command -v apk >/dev/null 2>&1; then
  apk add --no-cache bash sudo git make curl ca-certificates xz || true
elif command -v zypper >/dev/null 2>&1; then
  zypper --non-interactive in git make curl ca-certificates xz || true
fi

cd /root/ws
EOSCRIPT
  if [ -n "$CMD_TO_RUN" ]; then
    printf '%s\n' "$CMD_TO_RUN"
  else
    printf '%s\n' "bash"
  fi
}

"${RUN_BASE[@]}" "$(prepare_and_exec)"


