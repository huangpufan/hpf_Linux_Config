#!/usr/bin/env python3
"""Validate the tools promised by a preset.

This is intentionally read-only: it runs catalog check_cmd values and reports
the missing member tools without invoking any installer.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, Iterable, List


INSTALL_ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = INSTALL_ROOT / "agent-tools.json"

MINIMAL_MEMBERS = [
    "git",
    "gh",
    "tmux",
    "htop",
    "bat",
    "fzf",
    "zoxide",
]

DEV_CLI_EXTRA_MEMBERS = [
    "ranger",
    "ncdu",
    "tldr",
    "yq",
    "duf",
    "gdu",
    "xclip",
    "ag",
    "lazygit",
    "nvm",
    "eza",
    "broot",
    "sd",
    "ouch",
    "just",
    "delta",
    "doggo",
    "tre",
    "btm",
    "fd",
    "glow",
    "tealdeer",
    "fkill",
    "btop",
    "dust",
    "procs",
]

DEV_FULL_EXTRA_MEMBERS = [
    "build-essential",
    "xmake",
    "yazi",
    "mprocs",
    "pysocks",
    "gdbgui",
    "gdbfrontend",
    "zellij",
    "lnav",
    "bandwhich",
]

BOOTSTRAP_MEMBERS = [
    "folder-create",
    "bashrc",
    "git",
    "gh",
    "github-ssh",
]

PRESET_MEMBERS = {
    "bootstrap": BOOTSTRAP_MEMBERS,
    "minimal": MINIMAL_MEMBERS,
    "dev-cli": MINIMAL_MEMBERS + DEV_CLI_EXTRA_MEMBERS,
    "dev-full": MINIMAL_MEMBERS + DEV_CLI_EXTRA_MEMBERS + DEV_FULL_EXTRA_MEMBERS,
    "all-tools": BOOTSTRAP_MEMBERS
    + MINIMAL_MEMBERS
    + DEV_CLI_EXTRA_MEMBERS
    + DEV_FULL_EXTRA_MEMBERS,
}


def unique(items: Iterable[str]) -> List[str]:
    seen = set()
    result: List[str] = []
    for item in items:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


def normalize_preset_name(name: str) -> str:
    return name[7:] if name.startswith("preset-") else name


def load_tool_map() -> Dict[str, dict]:
    with CATALOG_PATH.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    tool_map: Dict[str, dict] = {}
    for category in data.get("categories", []):
        for tool in category.get("tools", []):
            tool_map[tool["id"]] = tool
    return tool_map


def run_check(tool_id: str, tool: dict) -> bool:
    completed = subprocess.run(
        ["bash", "-lc", tool["check_cmd"]],
        cwd=str(INSTALL_ROOT),
        text=True,
        capture_output=True,
    )
    status = "ok" if completed.returncode == 0 else "missing"
    print("{:<8} {} - {}".format(status, tool_id, tool["name"]))
    if completed.returncode == 0:
        return True

    details = (completed.stderr or completed.stdout).strip()
    if details:
        first_line = details.splitlines()[0]
        print("         {}".format(first_line))
    return False


def main(argv: List[str]) -> int:
    if len(argv) != 2:
        print("usage: check-preset.py <preset-name>", file=sys.stderr)
        return 2

    preset_name = normalize_preset_name(argv[1])
    members = PRESET_MEMBERS.get(preset_name)
    if members is None:
        print("unknown preset: {}".format(argv[1]), file=sys.stderr)
        return 2

    tool_map = load_tool_map()
    failed = False
    for tool_id in unique(members):
        tool = tool_map.get(tool_id)
        if tool is None:
            print("missing catalog entry: {}".format(tool_id), file=sys.stderr)
            failed = True
            continue
        failed = not run_check(tool_id, tool) or failed

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
