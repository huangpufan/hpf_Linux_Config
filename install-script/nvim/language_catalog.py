#!/usr/bin/env python3
"""Validate the Neovim language catalog and install its external tools."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from collections import Counter
from pathlib import Path
from typing import Any


OWNERS = {"apt", "npm", "cargo", "github_release", "mason"}


class CatalogError(RuntimeError):
    pass


def default_catalog_path() -> Path:
    return Path(__file__).resolve().parents[2] / "nvim" / "languages.json"


def load_catalog(path: Path) -> dict[str, Any]:
    try:
        catalog = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise CatalogError(f"cannot read language catalog {path}: {error}") from error
    validate_catalog(catalog)
    return catalog


def _require_string(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value:
        raise CatalogError(f"{label} must be a non-empty string")
    return value


def _tool_index(catalog: dict[str, Any]) -> dict[str, dict[str, Any]]:
    tools: dict[str, dict[str, Any]] = {}
    for tool in catalog.get("tools", []):
        tool_id = _require_string(tool.get("id"), "tool id")
        if tool_id in tools:
            raise CatalogError(f"duplicate tool id: {tool_id}")
        _require_string(tool.get("command"), f"tool command for {tool_id}")
        if tool.get("owner") not in OWNERS:
            raise CatalogError(f"unknown install owner for {tool_id}: {tool.get('owner')}")
        if not tool.get("package"):
            raise CatalogError(f"tool package is required: {tool_id}")
        tools[tool_id] = tool
    return tools


def validate_catalog(catalog: dict[str, Any]) -> None:
    if catalog.get("schema_version") != 1:
        raise CatalogError("unsupported language catalog schema version")
    if not isinstance(catalog.get("tools"), list):
        raise CatalogError("tools must be a list")
    if not isinstance(catalog.get("languages"), list):
        raise CatalogError("languages must be a list")
    if not isinstance(catalog.get("extra_parsers"), list):
        raise CatalogError("extra_parsers must be a list")

    tools = _tool_index(catalog)
    language_ids: set[str] = set()
    filetypes: set[str] = set()
    lsp_names: set[str] = set()
    parsers: set[str] = set()

    for language in catalog["languages"]:
        language_id = _require_string(language.get("id"), "language id")
        if language_id in language_ids:
            raise CatalogError(f"duplicate language id: {language_id}")
        language_ids.add(language_id)
        if not isinstance(language.get("filetypes"), list) or not language["filetypes"]:
            raise CatalogError(f"language needs filetypes: {language_id}")
        for field in ("parsers", "formatters", "linters", "fixtures"):
            if not isinstance(language.get(field), list):
                raise CatalogError(f"{field} must be a list: {language_id}")
        if not language["fixtures"]:
            raise CatalogError(f"language needs fixtures: {language_id}")

        for filetype in language["filetypes"]:
            _require_string(filetype, f"filetype for {language_id}")
            if filetype in filetypes:
                raise CatalogError(f"filetype conflict: {filetype}")
            filetypes.add(filetype)

        lsp = language.get("lsp")
        if lsp:
            name = _require_string(lsp.get("name"), f"LSP name for {language_id}")
            if name in lsp_names:
                raise CatalogError(f"duplicate LSP name: {name}")
            lsp_names.add(name)
            tool_id = _require_string(lsp.get("tool"), f"LSP tool for {language_id}")
            if tool_id not in tools:
                raise CatalogError(f"unknown LSP tool reference: {tool_id}")
            if tools[tool_id]["owner"] != "mason":
                raise CatalogError(f"LSP must be owned by Mason: {name}")

        language_parsers = set(language["parsers"])
        for parser in language["parsers"]:
            _require_string(parser, f"parser for {language_id}")
            if parser in parsers:
                raise CatalogError(f"duplicate parser: {parser}")
            parsers.add(parser)

        for field in ("formatters", "linters"):
            names: set[str] = set()
            for entry in language[field]:
                name = _require_string(entry.get("name"), f"{field} name for {language_id}")
                if name in names:
                    raise CatalogError(f"duplicate {field} entry for {language_id}: {name}")
                names.add(name)
                tool_id = _require_string(entry.get("tool"), f"tool reference for {name}")
                if tool_id not in tools:
                    raise CatalogError(f"unknown tool reference: {tool_id}")

        for fixture in language["fixtures"]:
            _require_string(fixture.get("filename"), f"fixture filename for {language_id}")
            if not isinstance(fixture.get("content"), str):
                raise CatalogError(f"fixture content is required: {fixture.get('filename')}")
            if fixture.get("parser") and fixture["parser"] not in language_parsers:
                raise CatalogError(f"fixture parser is not declared by language: {fixture['parser']}")
            if fixture.get("lsp") and not lsp:
                raise CatalogError(f"fixture requests LSP but language has none: {fixture['filename']}")

    for entry in catalog["extra_parsers"]:
        name = entry if isinstance(entry, str) else entry.get("name")
        _require_string(name, "extra parser name")
        if name in parsers:
            raise CatalogError(f"duplicate parser: {name}")
        parsers.add(name)


def projection(catalog: dict[str, Any]) -> dict[str, Any]:
    tools = _tool_index(catalog)
    lsp_names: list[str] = []
    mason_packages: list[str] = []
    parsers: list[str] = []
    formatters_by_ft: dict[str, list[str]] = {}
    linters_by_ft: dict[str, list[str]] = {}
    fixtures: list[dict[str, Any]] = []

    for language in catalog["languages"]:
        if lsp := language.get("lsp"):
            lsp_names.append(lsp["name"])
            mason_packages.append(tools[lsp["tool"]]["package"])
        parsers.extend(language["parsers"])
        formatter_names = [entry["name"] for entry in language["formatters"]]
        linter_names = [entry["name"] for entry in language["linters"]]
        for filetype in language["filetypes"]:
            if formatter_names:
                formatters_by_ft[filetype] = formatter_names
            if linter_names:
                linters_by_ft[filetype] = linter_names
        for fixture in language["fixtures"]:
            item = dict(fixture)
            item["language"] = language["id"]
            item["lsp_name"] = language.get("lsp", {}).get("name") if fixture.get("lsp") else None
            item["formatters"] = language["formatters"]
            item["linters"] = language["linters"]
            fixtures.append(item)

    for entry in catalog["extra_parsers"]:
        name = entry if isinstance(entry, str) else entry["name"]
        parsers.append(name)
        if isinstance(entry, dict) and entry.get("fixture"):
            item = dict(entry["fixture"])
            item["parser"] = name
            item["extra_parser"] = True
            fixtures.append(item)

    return {
        "lsp_names": lsp_names,
        "mason_packages": mason_packages,
        "parsers": parsers,
        "formatters_by_ft": formatters_by_ft,
        "linters_by_ft": linters_by_ft,
        "fixtures": fixtures,
    }


def installation_plan(catalog: dict[str, Any]) -> dict[str, list[Any]]:
    plan: dict[str, list[Any]] = {owner: [] for owner in sorted(OWNERS)}
    seen_apt: set[str] = set()
    for tool in catalog["tools"]:
        owner = tool["owner"]
        package = tool["package"]
        if owner == "apt":
            packages = package if isinstance(package, list) else [package]
            for name in packages:
                if name not in seen_apt:
                    seen_apt.add(name)
                    plan[owner].append(name)
        elif owner != "mason":
            plan[owner].append(
                {
                    "id": tool["id"],
                    "command": tool["command"],
                    "package": package,
                    "version": tool.get("version"),
                    "locked": bool(tool.get("locked")),
                    "required": tool.get("required", True),
                }
            )
        else:
            plan[owner].append(package)
    return plan


def _run(command: list[str], env: dict[str, str] | None = None) -> None:
    printable = " ".join(command)
    print(f"[language-catalog] run: {printable}", flush=True)
    subprocess.run(command, check=True, env=env)


def tool_satisfied(tool: dict[str, Any]) -> bool:
    command = shutil.which(tool["command"])
    if not command:
        return False
    version = tool.get("version")
    if not version:
        return True
    version_args = tool.get("version_args", ["--version"])
    result = subprocess.run(
        [command, *version_args],
        check=False,
        capture_output=True,
        text=True,
    )
    output = result.stdout + result.stderr
    return result.returncode == 0 and str(version) in output


def install_external_tools(catalog: dict[str, Any]) -> None:
    plan = installation_plan(catalog)
    tools = catalog["tools"]
    unsatisfied = {tool["id"] for tool in tools if tool["owner"] != "mason" and not tool_satisfied(tool)}
    apt_packages: list[str] = []
    seen_apt: set[str] = set()
    for tool in tools:
        if tool["owner"] == "apt" and tool["id"] in unsatisfied:
            packages = tool["package"] if isinstance(tool["package"], list) else [tool["package"]]
            for package in packages:
                if package not in seen_apt:
                    seen_apt.add(package)
                    apt_packages.append(package)
    if apt_packages:
        _run(["sudo", "apt-get", "install", "-y", *apt_packages])

    npm_tools = [tool for tool in plan["npm"] if tool["id"] in unsatisfied]
    if npm_tools:
        if not shutil.which("npm"):
            raise CatalogError("npm is required but is unavailable after apt installation")
        npm_packages = [
            f"{tool['package']}@{tool['version']}" if tool.get("version") else str(tool["package"])
            for tool in npm_tools
        ]
        _run(["npm", "install", "-g", *npm_packages])

    cargo_tools = [tool for tool in plan["cargo"] if tool["id"] in unsatisfied]
    if cargo_tools:
        if not shutil.which("cargo"):
            raise CatalogError("cargo is required but is unavailable after apt installation")
        env = dict(os.environ)
        env["PATH"] = f"{Path.home() / '.cargo' / 'bin'}:{env.get('PATH', '')}"
        for tool in cargo_tools:
            command = ["cargo", "install", str(tool["package"])]
            if tool.get("version"):
                command.extend(["--version", str(tool["version"])])
            if tool.get("locked"):
                command.append("--locked")
            _run(command, env=env)

    if plan["github_release"]:
        raise CatalogError("github_release tools are declared but no adapter is configured")


def verify_external_tools(catalog: dict[str, Any], include_mason: bool) -> None:
    missing: list[str] = []
    commands = Counter(
        tool["command"]
        for tool in catalog["tools"]
        if tool.get("required", True) and (include_mason or tool["owner"] != "mason")
    )
    for command in sorted(commands):
        if not shutil.which(command):
            missing.append(command)
    if missing:
        raise CatalogError("required commands are missing: " + ", ".join(missing))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--catalog", type=Path, default=default_catalog_path())
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("validate")
    subparsers.add_parser("plan")
    subparsers.add_parser("runtime")
    subparsers.add_parser("install")
    verify_parser = subparsers.add_parser("verify")
    verify_parser.add_argument("--include-mason", action="store_true")
    args = parser.parse_args(argv)

    try:
        catalog = load_catalog(args.catalog)
        if args.command == "validate":
            print(f"language catalog valid: {args.catalog}")
        elif args.command == "plan":
            print(json.dumps(installation_plan(catalog), indent=2, sort_keys=True))
        elif args.command == "runtime":
            print(json.dumps(projection(catalog), indent=2, sort_keys=True))
        elif args.command == "install":
            install_external_tools(catalog)
            verify_external_tools(catalog, include_mason=False)
        elif args.command == "verify":
            verify_external_tools(catalog, include_mason=args.include_mason)
    except (CatalogError, subprocess.CalledProcessError) as error:
        print(f"language catalog error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
