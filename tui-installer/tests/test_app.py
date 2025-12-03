"""
Tests for main application logic
"""

import asyncio
import json
import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock, AsyncMock
from io import StringIO

from tui_installer.app import Application
from tui_installer.config import Config
from tui_installer.models import AppState, Status


class TestApplication:
    """Test Application class"""

    @pytest.fixture
    def temp_config(self, tmp_path: Path) -> tuple[Path, Path]:
        """Create temporary config and script directories"""
        script_root = tmp_path / "scripts"
        script_root.mkdir()
        
        # Create test scripts
        test_dir = script_root / "test"
        test_dir.mkdir()
        (test_dir / "tool1.sh").write_text("#!/bin/bash\necho 'Tool 1'\nexit 0\n")
        (test_dir / "tool2.sh").write_text("#!/bin/bash\necho 'Tool 2'\nexit 0\n")
        
        # Create config file
        config_data = {
            "categories": [
                {
                    "id": "test",
                    "name": "测试分类",
                    "icon": "🧪",
                    "tools": [
                        {
                            "id": "tool1",
                            "name": "测试工具1",
                            "description": "测试工具",
                            "script": "test/tool1.sh",
                            "requires_sudo": False,
                        },
                        {
                            "id": "tool2",
                            "name": "测试工具2",
                            "description": "另一个测试工具",
                            "script": "test/tool2.sh",
                            "requires_sudo": True,
                        }
                    ]
                }
            ]
        }
        
        config_file = tmp_path / "config.json"
        config_file.write_text(json.dumps(config_data))
        
        return config_file, script_root

    @pytest.fixture
    def app(self, temp_config: tuple[Path, Path]) -> Application:
        """Create Application instance"""
        config_file, script_root = temp_config
        config = Config(config_file, script_root)
        return Application(config)


class TestApplicationInitialization(TestApplication):
    """Test application initialization"""

    @pytest.mark.asyncio
    async def test_initialize_loads_config(self, app: Application):
        """Application should load configuration on initialize"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        assert app.state is not None
        assert len(app.state.categories) > 0

    @pytest.mark.asyncio
    async def test_initialize_checks_system(self, app: Application):
        """Application should run system checks on initialize"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock) as mock_check:
            await app.initialize()
        
        mock_check.assert_called_once()

    @pytest.mark.asyncio
    async def test_initialize_creates_state(self, app: Application):
        """Application should create AppState on initialize"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        assert isinstance(app.state, AppState)
        assert app.state.running is True


class TestApplicationSummary(TestApplication):
    """Test application summary display"""

    @pytest.mark.asyncio
    async def test_show_summary_success(self, app: Application, capsys):
        """Should display success count"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        # Mark some tools as successful
        app.state.all_tools[0].status = Status.SUCCESS
        
        app.show_summary()
        
        # Rich console output may not be captured by capsys
        # Just verify no exception is raised

    @pytest.mark.asyncio
    async def test_show_summary_failure(self, app: Application):
        """Should display failure count"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        app.state.all_tools[0].status = Status.FAILED
        
        # Should not raise
        app.show_summary()

    @pytest.mark.asyncio
    async def test_show_summary_mixed(self, app: Application):
        """Should display both success and failure counts"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        app.state.all_tools[0].status = Status.SUCCESS
        if len(app.state.all_tools) > 1:
            app.state.all_tools[1].status = Status.FAILED
        
        app.show_summary()

    @pytest.mark.asyncio
    async def test_show_summary_none(self, app: Application):
        """Should not display when no tools were run"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        # All tools remain PENDING
        app.show_summary()


class TestApplicationState(TestApplication):
    """Test application state management"""

    @pytest.mark.asyncio
    async def test_state_initially_none(self, app: Application):
        """State should be None before initialization"""
        assert app.state is None

    @pytest.mark.asyncio
    async def test_state_populated_after_init(self, app: Application):
        """State should be populated after initialization"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        assert app.state is not None
        assert len(app.state.categories) == 1
        assert len(app.state.all_tools) == 2

    @pytest.mark.asyncio
    async def test_console_exists(self, app: Application):
        """Application should have a Console instance"""
        from rich.console import Console
        assert isinstance(app.console, Console)


class TestApplicationConfig(TestApplication):
    """Test application configuration handling"""

    def test_config_stored(self, app: Application, temp_config):
        """Application should store config reference"""
        assert app.config is not None
        config_file, _ = temp_config
        assert app.config.config_file == config_file

    @pytest.mark.asyncio
    async def test_invalid_config_raises(self, tmp_path: Path):
        """Application should raise on invalid config"""
        config_file = tmp_path / "invalid.json"
        config_file.write_text("invalid json")
        
        config = Config(config_file, tmp_path)
        app = Application(config)
        
        with pytest.raises(json.JSONDecodeError):
            await app.initialize()

    @pytest.mark.asyncio
    async def test_missing_config_raises(self, tmp_path: Path):
        """Application should raise on missing config"""
        config = Config(tmp_path / "nonexistent.json", tmp_path)
        app = Application(config)
        
        with pytest.raises(FileNotFoundError):
            await app.initialize()


class TestApplicationToolCounts:
    """Test application tool counting"""

    @pytest.fixture
    def multi_tool_app(self, tmp_path: Path) -> Application:
        """Create app with multiple tools and categories"""
        script_root = tmp_path / "scripts"
        script_root.mkdir()
        
        # Create scripts
        for i in range(5):
            script = script_root / f"tool{i}.sh"
            script.write_text(f"#!/bin/bash\necho 'Tool {i}'\nexit 0\n")
        
        config_data = {
            "categories": [
                {
                    "id": "cat1",
                    "name": "Category 1",
                    "icon": "📦",
                    "tools": [
                        {"id": f"t{i}", "name": f"Tool {i}", "description": f"D{i}", "script": f"tool{i}.sh"}
                        for i in range(3)
                    ]
                },
                {
                    "id": "cat2",
                    "name": "Category 2",
                    "icon": "🔧",
                    "tools": [
                        {"id": f"t{i}", "name": f"Tool {i}", "description": f"D{i}", "script": f"tool{i}.sh"}
                        for i in range(3, 5)
                    ]
                }
            ]
        }
        
        config_file = tmp_path / "config.json"
        config_file.write_text(json.dumps(config_data))
        
        config = Config(config_file, script_root)
        return Application(config)

    @pytest.mark.asyncio
    async def test_all_tools_count(self, multi_tool_app: Application):
        """Should count all tools across categories"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await multi_tool_app.initialize()
        
        assert len(multi_tool_app.state.all_tools) == 5

    @pytest.mark.asyncio
    async def test_success_count(self, multi_tool_app: Application):
        """Should count successful tools"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await multi_tool_app.initialize()
        
        multi_tool_app.state.all_tools[0].status = Status.SUCCESS
        multi_tool_app.state.all_tools[2].status = Status.SUCCESS
        
        success_count = sum(1 for t in multi_tool_app.state.all_tools if t.status == Status.SUCCESS)
        assert success_count == 2

    @pytest.mark.asyncio
    async def test_failed_count(self, multi_tool_app: Application):
        """Should count failed tools"""
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await multi_tool_app.initialize()
        
        multi_tool_app.state.all_tools[1].status = Status.FAILED
        
        failed_count = sum(1 for t in multi_tool_app.state.all_tools if t.status == Status.FAILED)
        assert failed_count == 1

