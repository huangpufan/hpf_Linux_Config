#!/usr/bin/env bash

PRESET_FAILURES=()

run_preset_step() {
  local label="$1"
  shift

  log_info "Running preset step: $label"
  if "$@"; then
    log_info "Preset step completed: $label"
    return 0
  fi

  local rc=$?
  log_err "Preset step failed: $label (exit $rc)"
  PRESET_FAILURES+=("$label:$rc")
  return 0
}

finish_preset() {
  if [ "${#PRESET_FAILURES[@]}" -eq 0 ]; then
    return 0
  fi

  log_err "Preset failed. Failed steps: ${PRESET_FAILURES[*]}"
  return 1
}
