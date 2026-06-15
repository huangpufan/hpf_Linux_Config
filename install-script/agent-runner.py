#!/usr/bin/env python3
"""Deterministic runner for HPF Linux Config install scripts."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import threading
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple


INSTALL_ROOT = Path(__file__).resolve().parent
REPO_ROOT = INSTALL_ROOT.parent
CONFIG_PATH = INSTALL_ROOT / "agent-tools.json"
LOG_ROOT = Path.home() / ".local" / "share" / "hpf-linux-config" / "logs"
EXPECTED_REPO_ROOT = Path.home() / "hpf_Linux_Config"
PRESET_TOOL_IDS = {
    "bootstrap": "preset-bootstrap",
    "minimal": "preset-minimal",
    "dev-cli": "preset-dev-cli",
    "dev-full": "preset-dev-full",
    "all-tools": "preset-all-tools",
}
PERSONAL_BOOTSTRAP_TOOL_IDS = {"preset-bootstrap", "preset-all-tools"}


@dataclass(frozen=True)
class ToolSpec:
    category_id: str
    category_name: str
    tool_id: str
    name: str
    description: str
    script: str
    requires_sudo: bool
    requires_ssh: bool
    check_cmd: str
    timeout: int

    @property
    def script_path(self) -> Path:
        return INSTALL_ROOT / self.script

    @property
    def display_id(self) -> str:
        if self.category_id == "presets" and self.tool_id.startswith("preset-"):
            return self.tool_id[len("preset-") :]
        return self.tool_id


Catalog = List[Tuple[str, str, List[ToolSpec]]]


def eprint(message: str) -> None:
    print(message, file=sys.stderr)


def assert_expected_repo_root() -> int:
    if REPO_ROOT != EXPECTED_REPO_ROOT:
        eprint(
            "[runner] repository must live at {} but is currently at {}".format(
                EXPECTED_REPO_ROOT, REPO_ROOT
            )
        )
        return 2
    return 0


def load_catalog() -> Tuple[Catalog, Dict[str, ToolSpec]]:
    with CONFIG_PATH.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    categories = data.get("categories")
    if not isinstance(categories, list):
        raise ValueError("agent-tools.json must contain a 'categories' list")

    catalog: Catalog = []
    tool_map: Dict[str, ToolSpec] = {}
    required_tool_fields = (
        "id",
        "name",
        "description",
        "script",
        "requires_sudo",
        "requires_ssh",
        "check_cmd",
        "timeout",
    )

    for category in categories:
        category_id = category.get("id")
        category_name = category.get("name")
        if not category_id or not category_name:
            raise ValueError("each category must include 'id' and 'name'")

        category_tools = category.get("tools")
        if not isinstance(category_tools, list):
            raise ValueError("each category must include a 'tools' list")

        tools: List[ToolSpec] = []
        for tool in category_tools:
            missing = [field for field in required_tool_fields if field not in tool]
            if missing:
                raise ValueError(
                    "tool in category {!r} missing fields: {}".format(
                        category_id, ", ".join(missing)
                    )
                )

            spec = ToolSpec(
                category_id=str(category_id),
                category_name=str(category_name),
                tool_id=str(tool["id"]),
                name=str(tool["name"]),
                description=str(tool["description"]),
                script=str(tool["script"]),
                requires_sudo=bool(tool["requires_sudo"]),
                requires_ssh=bool(tool["requires_ssh"]),
                check_cmd=str(tool["check_cmd"]),
                timeout=int(tool["timeout"]),
            )

            if spec.tool_id in tool_map:
                raise ValueError("duplicate tool id: {}".format(spec.tool_id))

            tool_map[spec.tool_id] = spec
            tools.append(spec)

        catalog.append((str(category_id), str(category_name), tools))

    return catalog, tool_map


def resolve_tool(tool_id: str, tool_map: Dict[str, ToolSpec]) -> ToolSpec:
    try:
        return tool_map[tool_id]
    except KeyError as exc:
        raise KeyError("unknown tool id: {}".format(tool_id)) from exc


def run_check_command(command: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["bash", "-lc", command],
        cwd=str(INSTALL_ROOT),
        text=True,
        capture_output=True,
    )


def ensure_sudo(spec: ToolSpec) -> int:
    if not spec.requires_sudo:
        return 0
    print("[runner] refreshing sudo credentials...")
    completed = subprocess.run(["sudo", "-v"], cwd=str(INSTALL_ROOT))
    if completed.returncode != 0:
        eprint("[runner] sudo -v failed")
    return completed.returncode


def ensure_ssh(spec: ToolSpec) -> int:
    if not spec.requires_ssh:
        return 0
    pubkeys = list((Path.home() / ".ssh").glob("*.pub"))
    if pubkeys:
        return 0
    eprint("[runner] tool requires SSH but no ~/.ssh/*.pub key was found")
    return 3


def is_bootstrap_owner() -> bool:
    owner = os.environ.get("HPF_BOOTSTRAP_OWNER", "hpf")
    current_user = os.environ.get("USER", "")

    try:
        login_user = subprocess.run(
            ["id", "-un"],
            cwd=str(INSTALL_ROOT),
            text=True,
            capture_output=True,
            check=False,
        ).stdout.strip()
    except OSError:
        login_user = ""

    home_name = Path.home().name
    return owner in {current_user, login_user, home_name}


def ensure_personal_bootstrap_allowed(spec: ToolSpec) -> int:
    if spec.tool_id not in PERSONAL_BOOTSTRAP_TOOL_IDS:
        return 0
    if is_bootstrap_owner():
        return 0
    if os.environ.get("HPF_BOOTSTRAP_CONFIRM_PERSONAL") == "yes":
        if not os.environ.get("HPF_GIT_EMAIL", "").strip():
            eprint("[runner] non-hpf personal bootstrap requires HPF_GIT_EMAIL")
            return 4
        return 0

    eprint(
        "[runner] {} is the personal hpf bootstrap path and uploads an SSH key".format(
            spec.tool_id
        )
    )
    eprint("[runner] ask the user before running it on a non-hpf account")
    eprint(
        "[runner] if approved, rerun with HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes and HPF_GIT_EMAIL"
    )
    return 4


def format_flags(spec: ToolSpec) -> str:
    flags: List[str] = []
    if spec.requires_sudo:
        flags.append("sudo")
    if spec.requires_ssh:
        flags.append("ssh")
    return " [{}]".format(", ".join(flags)) if flags else ""


def make_log_path(tool_id: str, create_dir: bool = True) -> Path:
    if create_dir:
        LOG_ROOT.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%dT%H%M%S")
    return LOG_ROOT / "{}_{}.log".format(tool_id, stamp)


def append_log(log_path: Path, line: str) -> None:
    with log_path.open("a", encoding="utf-8") as handle:
        handle.write(line)
        if not line.endswith("\n"):
            handle.write("\n")


def stream_script(spec: ToolSpec, log_path: Path) -> int:
    env = os.environ.copy()
    env["DEBIAN_FRONTEND"] = "noninteractive"
    command = ["bash", str(spec.script_path)]

    with log_path.open("w", encoding="utf-8") as log_handle:
        log_handle.write("tool_id: {}\n".format(spec.tool_id))
        log_handle.write("script: {}\n".format(spec.script_path))
        log_handle.write("cwd: {}\n".format(INSTALL_ROOT))
        log_handle.write("started_at: {}\n\n".format(datetime.now().isoformat()))
        log_handle.flush()

        process = subprocess.Popen(
            command,
            cwd=str(INSTALL_ROOT),
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        def pump_output() -> None:
            assert process.stdout is not None
            for line in process.stdout:
                sys.stdout.write(line)
                sys.stdout.flush()
                log_handle.write(line)
                log_handle.flush()

        thread = threading.Thread(target=pump_output, daemon=True)
        thread.start()

        try:
            return_code = process.wait(timeout=spec.timeout)
        except subprocess.TimeoutExpired:
            process.kill()
            return_code = 124
            message = "[runner] timed out after {} seconds".format(spec.timeout)
            eprint(message)
            log_handle.write(message + "\n")
            log_handle.flush()

        thread.join()
        log_handle.write("\nfinished_at: {}\n".format(datetime.now().isoformat()))
        log_handle.write("exit_code: {}\n".format(return_code))
        log_handle.flush()

    return return_code


def print_list(catalog: Catalog) -> int:
    for category_id, category_name, tools in catalog:
        print("{} [{}]".format(category_name, category_id))
        for spec in tools:
            label = spec.display_id if category_id == "presets" else spec.tool_id
            extra = ""
            if category_id == "presets":
                extra = " (tool id: {})".format(spec.tool_id)
            print(
                "  - {}{}{}: {}".format(
                    label,
                    extra,
                    format_flags(spec),
                    spec.description,
                )
            )
        print()
    return 0


def command_check(target: str, catalog: Catalog, tool_map: Dict[str, ToolSpec]) -> int:
    targets: List[ToolSpec] = []
    if target == "all":
        for _category_id, _category_name, tools in catalog:
            targets.extend(tools)
    else:
        try:
            targets.append(resolve_tool(target, tool_map))
        except KeyError as exc:
            eprint(str(exc))
            return 2

    failed = False
    for spec in targets:
        completed = run_check_command(spec.check_cmd)
        status = "ok" if completed.returncode == 0 else "missing"
        print("{:<8} {} - {}".format(status, spec.tool_id, spec.name))
        failed = failed or completed.returncode != 0

    return 1 if failed else 0


def print_dry_run(spec: ToolSpec, log_path: Path) -> None:
    print("[runner] dry run for {}".format(spec.tool_id))
    print("  script: {}".format(spec.script_path))
    print("  cwd: {}".format(INSTALL_ROOT))
    print("  timeout: {}s".format(spec.timeout))
    print("  requires sudo: {}".format("yes" if spec.requires_sudo else "no"))
    print("  requires ssh: {}".format("yes" if spec.requires_ssh else "no"))
    print("  check: {}".format(spec.check_cmd))
    print("  log: {}".format(log_path))


def command_install(tool_id: str, dry_run: bool, tool_map: Dict[str, ToolSpec]) -> int:
    try:
        spec = resolve_tool(tool_id, tool_map)
    except KeyError as exc:
        eprint(str(exc))
        return 2

    if not spec.script_path.is_file():
        eprint("[runner] missing script: {}".format(spec.script_path))
        return 2

    log_path = make_log_path(spec.tool_id, create_dir=not dry_run)
    if dry_run:
        print_dry_run(spec, log_path)
        return 0

    personal_bootstrap_result = ensure_personal_bootstrap_allowed(spec)
    if personal_bootstrap_result != 0:
        return personal_bootstrap_result

    ssh_result = ensure_ssh(spec)
    if ssh_result != 0:
        return ssh_result

    sudo_result = ensure_sudo(spec)
    if sudo_result != 0:
        return sudo_result

    print("[runner] executing {}".format(spec.tool_id))
    print("[runner] log: {}".format(log_path))
    install_return_code = stream_script(spec, log_path)
    if install_return_code != 0:
        eprint(
            "[runner] script failed for {} with exit code {}".format(
                spec.tool_id, install_return_code
            )
        )
        return install_return_code

    completed = run_check_command(spec.check_cmd)
    append_log(log_path, "")
    append_log(log_path, "verification_cmd: {}".format(spec.check_cmd))
    append_log(log_path, "verification_exit_code: {}".format(completed.returncode))
    if completed.stdout:
        append_log(log_path, completed.stdout.rstrip("\n"))
    if completed.stderr:
        append_log(log_path, completed.stderr.rstrip("\n"))

    if completed.returncode != 0:
        eprint(
            "[runner] install completed but verification failed for {}".format(
                spec.tool_id
            )
        )
        eprint("[runner] inspect log: {}".format(log_path))
        return 2

    print("[runner] verification passed for {}".format(spec.tool_id))
    print("[runner] log: {}".format(log_path))
    return 0


def command_preset(preset_name: str, dry_run: bool, tool_map: Dict[str, ToolSpec]) -> int:
    tool_id = PRESET_TOOL_IDS.get(preset_name)
    if tool_id is None:
        eprint("[runner] unknown preset: {}".format(preset_name))
        return 2
    return command_install(tool_id, dry_run, tool_map)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Deterministic runner for HPF Linux Config install scripts."
    )
    subparsers = parser.add_subparsers(dest="command")
    subparsers.required = True

    subparsers.add_parser("list", help="List catalogued tools and presets.")

    check_parser = subparsers.add_parser(
        "check", help="Run check_cmd for one tool or for all catalog entries."
    )
    check_parser.add_argument("target", help="tool id or 'all'")

    install_parser = subparsers.add_parser(
        "install", help="Run one tool or preset by tool id."
    )
    install_parser.add_argument("tool_id", help="tool id from agent-tools.json")
    install_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the resolved command without executing it.",
    )

    preset_parser = subparsers.add_parser(
        "preset", help="Run one of the named preset wrappers."
    )
    preset_parser.add_argument(
        "preset_name",
        choices=sorted(PRESET_TOOL_IDS),
        help="preset alias",
    )
    preset_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the resolved preset execution without running it.",
    )

    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    path_check = assert_expected_repo_root()
    if path_check != 0:
        return path_check

    try:
        catalog, tool_map = load_catalog()
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        eprint("[runner] failed to load catalog: {}".format(exc))
        return 2

    if args.command == "list":
        return print_list(catalog)
    if args.command == "check":
        return command_check(args.target, catalog, tool_map)
    if args.command == "install":
        return command_install(args.tool_id, args.dry_run, tool_map)
    if args.command == "preset":
        return command_preset(args.preset_name, args.dry_run, tool_map)

    parser.error("unknown command")
    return 2


if __name__ == "__main__":
    sys.exit(main())
