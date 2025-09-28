#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[ERROR] $0:$LINENO: $BASH_COMMAND" >&2' ERR

# Usage:
#   matrix.sh 'COMMAND'
#
# Edit the IMAGES array to add more distributions.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMAGES=(
  jammy
  focal
  ubuntu:24.04
)

CMD_TO_RUN="${1:-echo READY}"

for img in "${IMAGES[@]}"; do
  echo "==== Running on $img ===="
  bash "$SCRIPT_DIR/run.sh" "$img" "$CMD_TO_RUN" || {
    echo "[WARN] $img failed" >&2
  }
  echo
done


