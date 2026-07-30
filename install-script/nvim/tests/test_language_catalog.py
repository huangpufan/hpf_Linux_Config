from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path
from unittest import mock


MODULE_PATH = Path(__file__).resolve().parents[1] / "language_catalog.py"
SPEC = importlib.util.spec_from_file_location("language_catalog", MODULE_PATH)
assert SPEC and SPEC.loader
language_catalog = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(language_catalog)


class LanguageCatalogTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.catalog = language_catalog.load_catalog(language_catalog.default_catalog_path())

    def test_projection_preserves_current_capabilities(self) -> None:
        runtime = language_catalog.projection(self.catalog)
        self.assertEqual(
            runtime["lsp_names"],
            ["lua_ls", "clangd", "pyright", "bashls", "jsonls", "marksman", "ts_ls"],
        )
        self.assertEqual(
            runtime["parsers"],
            [
                "lua", "c", "cpp", "python", "bash", "json", "yaml", "markdown",
                "javascript", "typescript", "html", "css", "vim", "markdown_inline",
                "vimdoc", "regex", "just",
            ],
        )
        self.assertEqual(runtime["formatters_by_ft"]["lua"], ["stylua"])
        self.assertEqual(runtime["formatters_by_ft"]["rst"], ["rst_pandoc"])
        self.assertEqual(runtime["linters_by_ft"]["sh"], ["shellcheck"])
        self.assertEqual(runtime["linters_by_ft"]["rst"], ["rst_lint"])

    def test_unknown_tool_reference_fails(self) -> None:
        catalog = copy.deepcopy(self.catalog)
        catalog["languages"][0]["formatters"][0]["tool"] = "missing"
        with self.assertRaisesRegex(language_catalog.CatalogError, "unknown tool reference"):
            language_catalog.validate_catalog(catalog)

    def test_duplicate_tool_fails(self) -> None:
        catalog = copy.deepcopy(self.catalog)
        catalog["tools"].append(copy.deepcopy(catalog["tools"][0]))
        with self.assertRaisesRegex(language_catalog.CatalogError, "duplicate tool id"):
            language_catalog.validate_catalog(catalog)

    def test_duplicate_lsp_fails(self) -> None:
        catalog = copy.deepcopy(self.catalog)
        catalog["languages"][1]["lsp"]["name"] = catalog["languages"][0]["lsp"]["name"]
        with self.assertRaisesRegex(language_catalog.CatalogError, "duplicate LSP name"):
            language_catalog.validate_catalog(catalog)

    def test_filetype_conflict_fails(self) -> None:
        catalog = copy.deepcopy(self.catalog)
        catalog["languages"][1]["filetypes"].append(catalog["languages"][0]["filetypes"][0])
        with self.assertRaisesRegex(language_catalog.CatalogError, "filetype conflict"):
            language_catalog.validate_catalog(catalog)

    def test_json_roundtrip_keeps_stable_projection(self) -> None:
        roundtripped = json.loads(json.dumps(self.catalog, sort_keys=True))
        self.assertEqual(
            language_catalog.projection(self.catalog),
            language_catalog.projection(roundtripped),
        )

    def test_versioned_tool_is_only_satisfied_by_requested_version(self) -> None:
        tool = {"command": "stylua", "version": "2.5.2", "version_args": ["--version"]}
        with mock.patch.object(language_catalog.shutil, "which", return_value="/bin/stylua"), mock.patch.object(
            language_catalog.subprocess,
            "run",
            return_value=mock.Mock(returncode=0, stdout="stylua 2.5.2\n", stderr=""),
        ):
            self.assertTrue(language_catalog.tool_satisfied(tool))
        with mock.patch.object(language_catalog.shutil, "which", return_value="/bin/stylua"), mock.patch.object(
            language_catalog.subprocess,
            "run",
            return_value=mock.Mock(returncode=0, stdout="stylua 2.4.0\n", stderr=""),
        ):
            self.assertFalse(language_catalog.tool_satisfied(tool))


if __name__ == "__main__":
    unittest.main()
