#!/usr/bin/env bash
set -Eeuo pipefail

# Get list of tmux sessions
tmuxsessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || echo "")

if [ -z "$tmuxsessions" ]; then
    echo "No tmux sessions found."
    exit 0
fi

tmux_switch_to_session() {
    local session="$1"
    if [[ $tmuxsessions == *"$session"* ]]; then
        tmux switch-client -t "$session"
    fi
}

# Use fzf to select a session
choice=$(sort -rfu <<< "$tmuxsessions" \
    | fzf-tmux --prompt="Select session: " \
    | tr -d '\n')

if [ -n "$choice" ]; then
    tmux_switch_to_session "$choice"
fi
