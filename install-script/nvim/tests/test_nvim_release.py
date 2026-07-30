from __future__ import annotations

import importlib.util
import json
import os
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest import mock


MODULE_PATH = Path(__file__).resolve().parents[1] / "nvim-release.py"
SPEC = importlib.util.spec_from_file_location("nvim_release", MODULE_PATH)
assert SPEC and SPEC.loader
nvim_release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(nvim_release)


class NvimReleaseTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory(prefix="nvim-release-test-")
        self.root = Path(self.tempdir.name)
        self.home = self.root / "home"
        self.repo = self.root / "repo"
        self.release_root = self.home / ".local/share/hpf-linux-config/nvim"
        self.home.mkdir()
        (self.repo / "nvim").mkdir(parents=True)
        (self.repo / "nvim/languages.json").write_text("{}", encoding="utf-8")
        (self.repo / "nvim/lazy-lock.json").write_text("{}", encoding="utf-8")
        scripts = self.repo / "install-script/nvim"
        scripts.mkdir(parents=True)
        (scripts / "language_catalog.py").write_text("", encoding="utf-8")
        shutil.copy2(MODULE_PATH.parent / "nvim-launcher", scripts / "nvim-launcher")
        (self.home / ".config").mkdir()
        (self.home / ".config/nvim").symlink_to(self.repo / "nvim")

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def installer(self, fail_stage: str | None = None) -> nvim_release.ReleaseInstaller:
        return nvim_release.ReleaseInstaller(
            self.repo,
            self.home,
            release_root=self.release_root,
            fail_stage=fail_stage,
            skip_external_tools=True,
            skip_download=True,
        )

    def make_release(self, name: str) -> Path:
        release = self.release_root / "releases" / name
        binary = release / "nvim/bin/nvim"
        binary.parent.mkdir(parents=True)
        binary.write_text("#!/usr/bin/env bash\nexit 0\n", encoding="utf-8")
        binary.chmod(0o755)
        for relative in ("xdg/data", "xdg/state", "xdg/cache", "xdg/config"):
            (release / relative).mkdir(parents=True, exist_ok=True)
        return release

    @staticmethod
    def link(path: Path, target: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.symlink_to(target)

    def test_activation_smoke_failure_restores_links(self) -> None:
        old = self.make_release("old")
        older = self.make_release("older")
        candidate = self.make_release("new.candidate")
        self.link(self.release_root / "current", old)
        self.link(self.release_root / "previous", older)
        launcher = self.home / ".local/bin/nvim"
        launcher.parent.mkdir(parents=True)
        launcher.symlink_to(old / "nvim/bin/nvim")
        installer = self.installer(fail_stage="activation_smoke")
        installer.old_current = old
        installer.old_previous = older
        installer._active_release_processes = lambda: []
        with self.assertRaisesRegex(nvim_release.ReleaseError, "activation_smoke"):
            installer.activate(candidate)
        self.assertEqual((self.release_root / "current").resolve(), old)
        self.assertEqual((self.release_root / "previous").resolve(), older)
        self.assertFalse((self.release_root / "releases/new").exists())
        self.assertTrue(launcher.is_symlink())
        self.assertEqual(launcher.resolve(), (old / "nvim/bin/nvim").resolve())

    def test_failure_before_activation_preserves_active_release_and_data(self) -> None:
        old = self.make_release("old")
        self.link(self.release_root / "current", old)
        persistent = self.release_root / "persistent/sessions/session.vim"
        persistent.parent.mkdir(parents=True)
        persistent.write_text("keep", encoding="utf-8")
        installer = self.installer(fail_stage="verify")
        installer.preflight = lambda: None
        installer.install_external_tools = lambda: None
        installer.prepare_persistent_data = lambda: None
        installer.import_legacy_release = lambda: None
        candidate = self.make_release("new.candidate")
        installer.prepare_candidate = lambda: candidate
        installer.build_candidate = lambda _candidate: None
        installer.cleanup_old_releases = lambda _active: None
        with self.assertRaisesRegex(nvim_release.ReleaseError, "verify"):
            installer.install()
        self.assertEqual((self.release_root / "current").resolve(), old)
        self.assertEqual(persistent.read_text(encoding="utf-8"), "keep")

    def test_non_symlink_config_is_rejected(self) -> None:
        (self.home / ".config/nvim").unlink()
        (self.home / ".config/nvim").mkdir()
        installer = self.installer()
        with mock.patch.object(shutil, "disk_usage", return_value=shutil._ntuple_diskusage(10, 0, 10)):
            os.environ["HPF_NVIM_MIN_FREE_BYTES"] = "1"
            try:
                with self.assertRaisesRegex(nvim_release.ReleaseError, "non-symlink"):
                    installer.preflight()
            finally:
                os.environ.pop("HPF_NVIM_MIN_FREE_BYTES", None)

    def test_insufficient_space_is_rejected(self) -> None:
        installer = self.installer()
        with mock.patch.object(shutil, "disk_usage", return_value=shutil._ntuple_diskusage(10, 9, 1)):
            os.environ["HPF_NVIM_MIN_FREE_BYTES"] = "2"
            try:
                with self.assertRaisesRegex(nvim_release.ReleaseError, "insufficient free space"):
                    installer.preflight()
            finally:
                os.environ.pop("HPF_NVIM_MIN_FREE_BYTES", None)

    def test_active_process_blocks_switch(self) -> None:
        candidate = self.make_release("new.candidate")
        installer = self.installer()
        installer._active_release_processes = lambda: [101, 202]
        with self.assertRaisesRegex(nvim_release.ReleaseError, "101, 202"):
            installer.activate(candidate)
        self.assertTrue(candidate.is_dir())

    def test_activation_rebinds_existing_persistent_links(self) -> None:
        candidate = self.make_release("new.candidate")
        installer = self.installer()
        installer.prepare_persistent_data()
        installer._link_persistent(candidate)
        installer._active_release_processes = lambda: []
        installer._run = lambda *args, **kwargs: None
        installer._write_manifest = lambda *args, **kwargs: None

        active = installer.activate(candidate)

        for release_relative, persistent_relative in nvim_release.PERSISTENT_LINKS.items():
            link = active / release_relative
            self.assertTrue(link.is_symlink())
            self.assertEqual(link.resolve(), (self.release_root / "persistent" / persistent_relative).resolve())

    def test_download_retries_and_resumes_before_extracting(self) -> None:
        installer = nvim_release.ReleaseInstaller(
            self.repo,
            self.home,
            release_root=self.release_root,
            skip_external_tools=True,
            skip_download=False,
        )
        archive_root = self.root / "archive-root"
        binary = archive_root / "nvim-linux-x86_64/bin/nvim"
        binary.parent.mkdir(parents=True)
        binary.write_text("binary", encoding="utf-8")
        archive = self.root / "nvim.tar.gz"
        with tarfile.open(archive, "w:gz") as package:
            package.add(archive_root / "nvim-linux-x86_64", arcname="nvim-linux-x86_64")

        commands: list[tuple[list[str], int | None]] = []

        def fake_run(command: list[str], *, env=None, timeout=None) -> None:
            commands.append((command, timeout))
            if command[0] == "curl":
                shutil.copy2(archive, Path(command[command.index("--output") + 1]))

        installer._run = fake_run
        installer._release_id = lambda: "download-test"
        candidate = installer.prepare_candidate()

        curl, timeout = commands[0]
        self.assertEqual(curl[0], "curl")
        self.assertIn("--retry-all-errors", curl)
        self.assertEqual(curl[curl.index("--retry") + 1], "5")
        self.assertEqual(curl[curl.index("--continue-at") + 1], "-")
        self.assertEqual(timeout, 930)
        self.assertTrue((candidate / "nvim/bin/nvim").is_file())

    def test_candidate_build_restores_plugin_lock_without_updating_it(self) -> None:
        candidate = self.make_release("new.candidate")
        installer = self.installer()
        commands: list[list[str]] = []
        installer._run = lambda command, **kwargs: commands.append(command)

        installer.build_candidate(candidate)

        self.assertIn("+Lazy! restore", commands[0])
        self.assertNotIn("+Lazy! sync", commands[0])

    def test_release_id_keeps_loader_cache_paths_below_name_limit(self) -> None:
        installer = self.installer()
        release_id = installer._release_id()
        self.assertLessEqual(len(release_id), 22)
        encoded_cache_name = (
            str(self.release_root / "releases" / (release_id + ".candidate") / "xdg/data/nvim/lazy")
            + "/nvim-treesitter-textobjects/lua/nvim-treesitter-textobjects/repeatable_move.lua"
        ).replace("/", "%2f") + "c"
        self.assertLess(len(encoded_cache_name.encode()), 256)

    def test_launcher_pins_resolved_release_environment(self) -> None:
        first = self.make_release("first")
        second = self.make_release("second")
        output = self.root / "launcher-output.json"
        binary = first / "nvim/bin/nvim"
        binary.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os\n"
            f"open({str(output)!r}, 'w').write(json.dumps({{'release': os.environ['HPF_NVIM_RELEASE_DIR'], 'data': os.environ['XDG_DATA_HOME'], 'config': os.environ['XDG_CONFIG_HOME']}}))\n",
            encoding="utf-8",
        )
        binary.chmod(0o755)
        current = self.release_root / "current"
        self.link(current, first)
        launcher = self.repo / "install-script/nvim/nvim-launcher"
        env = dict(os.environ, HOME=str(self.home), HPF_NVIM_RELEASE_ROOT=str(self.release_root))
        subprocess.run([str(launcher)], check=True, env=env)
        current.unlink()
        current.symlink_to(second)
        observed = json.loads(output.read_text(encoding="utf-8"))
        self.assertEqual(observed["release"], str(first))
        self.assertEqual(observed["data"], str(first / "xdg/data"))
        self.assertEqual(observed["config"], str(first / "xdg/config"))

    def test_success_keeps_current_and_previous_only(self) -> None:
        old = self.make_release("old")
        stale = self.make_release("stale")
        new = self.make_release("new")
        self.link(self.release_root / "current", new)
        self.link(self.release_root / "previous", old)
        self.installer().cleanup_old_releases(new)
        self.assertTrue(new.is_dir())
        self.assertTrue(old.is_dir())
        self.assertFalse(stale.exists())

    def test_created_config_link_is_removed_when_candidate_fails(self) -> None:
        (self.home / ".config/nvim").unlink()
        installer = self.installer(fail_stage="download")
        installer.preflight = lambda: None
        installer.install_external_tools = lambda: None
        installer.prepare_persistent_data = lambda: None
        installer.import_legacy_release = lambda: None
        with self.assertRaisesRegex(nvim_release.ReleaseError, "download"):
            installer.install()
        self.assertFalse((self.home / ".config/nvim").exists())
        self.assertFalse((self.home / ".config/nvim").is_symlink())


if __name__ == "__main__":
    unittest.main()
