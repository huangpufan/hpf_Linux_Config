#!/usr/bin/env python3
"""Transactional Neovim release installer."""

from __future__ import annotations

import argparse
import contextlib
import datetime as dt
import fcntl
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import uuid
from pathlib import Path
from typing import Iterator


NEOVIM_VERSION = "0.12.2"
NEOVIM_ARCHIVE = "nvim-linux-x86_64.tar.gz"
NEOVIM_URL = f"https://github.com/neovim/neovim/releases/download/v{NEOVIM_VERSION}/{NEOVIM_ARCHIVE}"
MIN_FREE_BYTES = 3 * 1024 * 1024 * 1024
PERSISTENT_LINKS = {
    "xdg/data/nvim/sessions": "sessions",
    "xdg/data/nvim/bookmarks": "bookmarks",
    "xdg/state/nvim/undo": "undo",
    "xdg/state/nvim/shada": "shada",
    "xdg/state/nvim/grug-far": "grug-far",
    "xdg/state/nvim/blink/cmp": "blink/cmp",
}


class ReleaseError(RuntimeError):
    pass


class ReleaseInstaller:
    def __init__(
        self,
        repo_root: Path,
        home: Path,
        *,
        release_root: Path | None = None,
        fail_stage: str | None = None,
        skip_external_tools: bool = False,
        skip_download: bool = False,
    ) -> None:
        self.repo_root = repo_root.resolve()
        self.home = home.resolve()
        self.release_root = (release_root or self.home / ".local/share/hpf-linux-config/nvim").resolve()
        self.releases_dir = self.release_root / "releases"
        self.persistent_dir = self.release_root / "persistent"
        self.current_link = self.release_root / "current"
        self.previous_link = self.release_root / "previous"
        self.config_link = self.home / ".config/nvim"
        self.launcher = self.home / ".local/bin/nvim"
        self.fail_stage = fail_stage or os.environ.get("HPF_NVIM_FAIL_STAGE")
        self.skip_external_tools = skip_external_tools
        self.skip_download = skip_download
        self.candidate: Path | None = None
        self.old_current = self._read_link(self.current_link)
        self.old_previous = self._read_link(self.previous_link)
        self.legacy_binary = self._legacy_binary()
        self.imported_legacy: Path | None = None
        self.launcher_backup: bytes | str | None = None
        self.launcher_backup_mode: int | None = None

    def _fail_if_injected(self, stage: str) -> None:
        if self.fail_stage == stage:
            raise ReleaseError(f"injected failure at stage: {stage}")

    @staticmethod
    def _read_link(path: Path) -> Path | None:
        if not path.is_symlink():
            return None
        try:
            return path.resolve(strict=True)
        except OSError:
            return None

    def _legacy_binary(self) -> Path | None:
        if self.old_current:
            current_binary = self.old_current / "nvim/bin/nvim"
            if current_binary.is_file():
                return current_binary.resolve()
        if self.launcher.is_symlink():
            target = self.launcher.resolve(strict=False)
            if target.name == "nvim" and target.parent.name == "bin":
                return target
        found = shutil.which("nvim")
        if found:
            resolved = Path(found).resolve()
            if resolved != self.launcher.resolve(strict=False):
                return resolved
        return None

    @staticmethod
    def _sha256(path: Path) -> str:
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
        return digest.hexdigest()

    def _release_id(self) -> str:
        timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d%H%M%S")
        return f"{timestamp}-{uuid.uuid4().hex[:6]}"

    @contextlib.contextmanager
    def lock(self) -> Iterator[None]:
        self.release_root.mkdir(parents=True, exist_ok=True)
        lock_path = self.release_root / "install.lock"
        with lock_path.open("a+", encoding="utf-8") as handle:
            try:
                fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError as error:
                raise ReleaseError(f"another Neovim release operation holds {lock_path}") from error
            yield

    def preflight(self) -> None:
        if self.config_link.exists() and not self.config_link.is_symlink():
            raise ReleaseError(f"refusing to replace non-symlink config directory: {self.config_link}")
        if self.config_link.is_symlink() and self.config_link.resolve() != self.repo_root / "nvim":
            raise ReleaseError(f"config link does not point to {self.repo_root / 'nvim'}")
        usage = shutil.disk_usage(self.release_root)
        required = int(os.environ.get("HPF_NVIM_MIN_FREE_BYTES", str(MIN_FREE_BYTES)))
        if usage.free < required:
            raise ReleaseError(f"insufficient free space: need {required} bytes, have {usage.free}")
        for command in ("git", "curl", "tar", "python3"):
            if not shutil.which(command):
                raise ReleaseError(f"required system command is missing: {command}")
        if not (self.repo_root / "nvim/languages.json").is_file():
            raise ReleaseError("language catalog is missing")
        self._run([sys.executable, str(self.repo_root / "install-script/nvim/language_catalog.py"), "validate"])
        self._fail_if_injected("preflight")

    @staticmethod
    def _run(command: list[str], *, env: dict[str, str] | None = None, timeout: int | None = None) -> None:
        print("[nvim-release] run:", " ".join(command), flush=True)
        subprocess.run(command, check=True, env=env, timeout=timeout)

    def install_external_tools(self) -> None:
        if self.skip_external_tools:
            return
        self._fail_if_injected("external_tools")
        self._run([sys.executable, str(self.repo_root / "install-script/nvim/language_catalog.py"), "install"])

    def prepare_persistent_data(self) -> None:
        legacy_data = self.home / ".local/share/nvim"
        legacy_state = self.home / ".local/state/nvim"
        source_paths = {
            "sessions": legacy_data / "sessions",
            "bookmarks": legacy_data / "bookmarks",
            "undo": legacy_state / "undo",
            "shada": legacy_state / "shada",
            "grug-far": legacy_state / "grug-far",
            "blink/cmp": legacy_state / "blink/cmp",
        }
        for relative, source in source_paths.items():
            destination = self.persistent_dir / relative
            if destination.exists():
                continue
            destination.parent.mkdir(parents=True, exist_ok=True)
            if source.is_dir():
                shutil.copytree(source, destination)
            else:
                destination.mkdir(parents=True, exist_ok=True)

    def prepare_config_link(self) -> bool:
        if self.config_link.is_symlink():
            return False
        if self.config_link.exists():
            raise ReleaseError(f"refusing to replace non-symlink config directory: {self.config_link}")
        self.config_link.parent.mkdir(parents=True, exist_ok=True)
        self.config_link.symlink_to(self.repo_root / "nvim")
        return True

    def import_legacy_release(self) -> None:
        if self.old_current or not self.legacy_binary or not self.legacy_binary.is_file():
            return
        legacy_data = self.home / ".local/share/nvim"
        legacy_state = self.home / ".local/state/nvim"
        legacy_cache = self.home / ".cache/nvim"
        if not legacy_data.is_dir():
            return

        release = self.releases_dir / f"legacy-{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ')}"
        release.mkdir(parents=True)
        shutil.copytree(self.legacy_binary.parent.parent, release / "nvim", symlinks=True)

        persistent_names = {
            legacy_data: {"sessions", "bookmarks"},
            legacy_state: {"undo", "shada", "grug-far", "blink"},
        }
        for source, destination in (
            (legacy_data, release / "xdg/data/nvim"),
            (legacy_state, release / "xdg/state/nvim"),
            (legacy_cache, release / "xdg/cache/nvim"),
        ):
            if source.is_dir():
                ignored = persistent_names.get(source, set())
                shutil.copytree(source, destination, symlinks=True, ignore=lambda _path, names: ignored.intersection(names))
            else:
                destination.mkdir(parents=True, exist_ok=True)
        config_dir = release / "xdg/config"
        config_dir.mkdir(parents=True, exist_ok=True)
        (config_dir / "nvim").symlink_to(self.repo_root / "nvim")
        self._link_persistent(release)
        self._write_manifest(release, verified=True, activated=True, imported=True)
        self.imported_legacy = release
        self.old_current = release

    def prepare_candidate(self) -> Path:
        self._fail_if_injected("download")
        self.releases_dir.mkdir(parents=True, exist_ok=True)
        candidate = self.releases_dir / (self._release_id() + ".candidate")
        candidate.mkdir()
        self.candidate = candidate

        for relative in ("xdg/config", "xdg/data", "xdg/state", "xdg/cache"):
            (candidate / relative).mkdir(parents=True, exist_ok=True)
        (candidate / "xdg/config/nvim").symlink_to(self.repo_root / "nvim")
        self._link_persistent(candidate)

        if self.skip_download:
            if not self.legacy_binary or not self.legacy_binary.is_file():
                raise ReleaseError("cannot seed candidate without a legacy Neovim binary")
            source_root = self.legacy_binary.parent.parent
            shutil.copytree(source_root, candidate / "nvim", symlinks=True)
        else:
            with tempfile.TemporaryDirectory(prefix="hpf-nvim-download-") as temp_dir:
                archive = Path(temp_dir) / NEOVIM_ARCHIVE
                self._run(
                    [
                        "curl",
                        "--fail-with-body",
                        "--location",
                        "--retry",
                        "5",
                        "--retry-all-errors",
                        "--retry-delay",
                        "2",
                        "--connect-timeout",
                        "20",
                        "--max-time",
                        "900",
                        "--continue-at",
                        "-",
                        "--output",
                        str(archive),
                        NEOVIM_URL,
                    ],
                    timeout=930,
                )
                with tarfile.open(archive, "r:gz") as package:
                    package.extractall(temp_dir, filter="data")
                shutil.copytree(Path(temp_dir) / "nvim-linux-x86_64", candidate / "nvim", symlinks=True)
        self._fail_if_injected("binary")

        provider = candidate / "xdg/data/nvim/python3-provider"
        self._run(["python3", "-m", "venv", str(provider)])
        self._fail_if_injected("provider")
        self._run([str(provider / "bin/python"), "-m", "pip", "install", "--upgrade", "pip", "pynvim"])
        return candidate

    def _link_persistent(self, release: Path) -> None:
        for release_relative, persistent_relative in PERSISTENT_LINKS.items():
            link = release / release_relative
            target = self.persistent_dir / persistent_relative
            target.mkdir(parents=True, exist_ok=True)
            link.parent.mkdir(parents=True, exist_ok=True)
            if link.exists() or link.is_symlink():
                if link.is_dir() and not link.is_symlink():
                    shutil.rmtree(link)
                else:
                    link.unlink()
            link.symlink_to(target)

    def _release_env(self, release: Path) -> dict[str, str]:
        env = dict(os.environ)
        env.update(
            {
                "HOME": str(self.home),
                "XDG_CONFIG_HOME": str(release / "xdg/config"),
                "XDG_DATA_HOME": str(release / "xdg/data"),
                "XDG_STATE_HOME": str(release / "xdg/state"),
                "XDG_CACHE_HOME": str(release / "xdg/cache"),
                "HPF_NVIM_RELEASE_DIR": str(release),
                "PATH": f"{release / 'nvim/bin'}:{release / 'xdg/data/nvim/mason/bin'}:{self.home / '.local/bin'}:{self.home / '.cargo/bin'}:{env.get('PATH', '')}",
            }
        )
        return env

    def build_candidate(self, candidate: Path) -> None:
        binary = candidate / "nvim/bin/nvim"
        env = self._release_env(candidate)
        self._fail_if_injected("lazy")
        startup_guard = "+lua if vim.v.errmsg ~= '' then io.stderr:write(vim.v.errmsg .. '\\n'); vim.cmd('cquit 1') end"
        self._run([str(binary), "--headless", "+Lazy! restore", startup_guard, "+qa"], env=env, timeout=900)
        self._fail_if_injected("mason")
        self._run(
            [
                str(binary),
                "--headless",
                "+lua local ok,err=xpcall(function() dofile([["
                + str(self.repo_root / "nvim/scripts/install_mason.lua")
                + "]]) end, debug.traceback); if not ok then io.stderr:write(err .. '\\n'); vim.cmd('cquit 1') end",
                startup_guard,
                "+qa",
            ],
            env=env,
            timeout=900,
        )
        self._fail_if_injected("parsers")
        self._run(
            [
                str(binary),
                "--headless",
                "+lua local ok,err=xpcall(function() require('nvim-treesitter').install(require('config.languages').runtime().parsers):wait(600000) end, debug.traceback); if not ok then io.stderr:write(err .. '\\n'); vim.cmd('cquit 1') end",
                startup_guard,
                "+qa",
            ],
            env=env,
            timeout=700,
        )

    def verify_candidate(self, candidate: Path) -> None:
        self._fail_if_injected("verify")
        env = self._release_env(candidate)
        verify = self.repo_root / "install-script/nvim/nvim-verify.sh"
        self._run(["bash", str(verify)], env=env, timeout=900)
        self._write_manifest(candidate, verified=True, activated=False)

    def _write_manifest(self, release: Path, *, verified: bool, activated: bool, imported: bool = False) -> None:
        commit = subprocess.run(
            ["git", "-C", str(self.repo_root), "rev-parse", "HEAD"],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
        manifest = {
            "release_id": release.name[:-10] if release.name.endswith(".candidate") else release.name,
            "neovim_version": NEOVIM_VERSION,
            "git_commit": commit,
            "lazy_lock_sha256": self._sha256(self.repo_root / "nvim/lazy-lock.json"),
            "language_catalog_sha256": self._sha256(self.repo_root / "nvim/languages.json"),
            "created_at": dt.datetime.now(dt.timezone.utc).isoformat(),
            "verification": {"candidate": verified, "activation_smoke": activated},
            "imported_legacy": imported,
        }
        temp = release / "manifest.json.tmp"
        temp.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        temp.replace(release / "manifest.json")

    def _active_release_processes(self) -> list[int]:
        needles = set()
        if self.old_current:
            needles.add(str((self.old_current / "nvim/bin/nvim").resolve()))
        if self.legacy_binary:
            needles.add(str(self.legacy_binary.resolve()))
        if not needles:
            return []
        processes: list[int] = []
        proc_root = Path("/proc")
        for entry in proc_root.iterdir():
            if not entry.name.isdigit() or int(entry.name) == os.getpid():
                continue
            try:
                executable = (entry / "exe").resolve()
            except OSError:
                continue
            if str(executable) in needles:
                processes.append(int(entry.name))
        return processes

    @staticmethod
    def _atomic_link(link: Path, target: Path | None) -> None:
        if target is None:
            link.unlink(missing_ok=True)
            return
        link.parent.mkdir(parents=True, exist_ok=True)
        temporary = link.with_name(f".{link.name}.{uuid.uuid4().hex}.tmp")
        temporary.symlink_to(target)
        temporary.replace(link)

    def _install_launcher(self) -> None:
        source = self.repo_root / "install-script/nvim/nvim-launcher"
        self.launcher.parent.mkdir(parents=True, exist_ok=True)
        if self.launcher.is_symlink():
            self.launcher_backup = os.readlink(self.launcher)
            self.launcher_backup_mode = None
        elif self.launcher.exists():
            self.launcher_backup = self.launcher.read_bytes()
            self.launcher_backup_mode = self.launcher.stat().st_mode & 0o777
        else:
            self.launcher_backup = None
            self.launcher_backup_mode = None
        temporary = self.launcher.with_name(f".nvim-launcher.{uuid.uuid4().hex}.tmp")
        shutil.copy2(source, temporary)
        temporary.chmod(0o755)
        temporary.replace(self.launcher)

    def _restore_launcher(self) -> None:
        self.launcher.unlink(missing_ok=True)
        if isinstance(self.launcher_backup, str):
            self.launcher.symlink_to(self.launcher_backup)
        elif isinstance(self.launcher_backup, bytes):
            self.launcher.write_bytes(self.launcher_backup)
            self.launcher.chmod(self.launcher_backup_mode or 0o755)

    def activate(self, candidate: Path) -> Path:
        processes = self._active_release_processes()
        if processes:
            raise ReleaseError("refusing to switch while active Neovim processes use current release: " + ", ".join(map(str, processes)))
        self._fail_if_injected("activate")

        final = candidate.with_name(candidate.name[:-10] if candidate.name.endswith(".candidate") else candidate.name)
        candidate.replace(final)
        self.candidate = final
        self._link_persistent(final)
        if not self.config_link.exists() and not self.config_link.is_symlink():
            self.config_link.parent.mkdir(parents=True, exist_ok=True)
            self.config_link.symlink_to(self.repo_root / "nvim")
        try:
            self._atomic_link(self.previous_link, self.old_current)
            self._atomic_link(self.current_link, final)
            self._install_launcher()
            self._fail_if_injected("activation_smoke")
            smoke_env = dict(os.environ, HOME=str(self.home), HPF_NVIM_RELEASE_ROOT=str(self.release_root))
            self._run([str(self.launcher), "--headless", "+qa"], env=smoke_env, timeout=120)
            self._write_manifest(final, verified=True, activated=True)
        except Exception:
            self._atomic_link(self.current_link, self.old_current)
            self._atomic_link(self.previous_link, self.old_previous)
            self._restore_launcher()
            if final.is_dir():
                shutil.rmtree(final)
            self.candidate = None
            raise
        return final

    def cleanup_old_releases(self, active: Path) -> None:
        keep = {active}
        previous = self._read_link(self.previous_link)
        if previous:
            keep.add(previous)
        for release in self.releases_dir.iterdir():
            if release not in keep and release.name.endswith(".candidate"):
                shutil.rmtree(release)
            elif release not in keep and release.is_dir():
                shutil.rmtree(release)

    def install(self) -> Path:
        with self.lock():
            created_config_link = False
            try:
                self.preflight()
                self.install_external_tools()
                self.prepare_persistent_data()
                self.import_legacy_release()
                created_config_link = self.prepare_config_link()
                candidate = self.prepare_candidate()
                self.build_candidate(candidate)
                self.verify_candidate(candidate)
                active = self.activate(candidate)
                self.cleanup_old_releases(active)
                return active
            except Exception:
                if self.candidate and self.candidate.exists() and self.candidate.name.endswith(".candidate"):
                    shutil.rmtree(self.candidate)
                if created_config_link and self.config_link.is_symlink():
                    self.config_link.unlink()
                raise


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("install", "preflight"), nargs="?", default="install")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--home", type=Path, default=Path.home())
    parser.add_argument("--release-root", type=Path)
    parser.add_argument("--skip-external-tools", action="store_true")
    parser.add_argument("--skip-download", action="store_true")
    args = parser.parse_args(argv)
    installer = ReleaseInstaller(
        args.repo_root,
        args.home,
        release_root=args.release_root,
        skip_external_tools=args.skip_external_tools,
        skip_download=args.skip_download,
    )
    try:
        if args.command == "preflight":
            with installer.lock():
                installer.preflight()
        else:
            active = installer.install()
            print(f"Neovim {NEOVIM_VERSION} release activated: {active}")
    except (ReleaseError, subprocess.CalledProcessError, subprocess.TimeoutExpired, OSError) as error:
        print(f"nvim release error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
