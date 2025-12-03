"""
Integration tests for TUI Installer
Tests complete workflows and component interactions
"""

import asyncio
import json
import pytest
from pathlib import Path
from unittest.mock import patch, AsyncMock

from tui_installer.app import Application
from tui_installer.config import Config
from tui_installer.models import AppState, Category, Tool, Status
from tui_installer.executor import execute_tool, install_selected
from tui_installer.system import check_system
from tui_installer.input import handle_input


class TestEndToEndWorkflow:
    """Test complete installation workflows"""

    @pytest.fixture
    def complete_setup(self, tmp_path: Path) -> tuple[Application, Path]:
        """Create complete test environment"""
        script_root = tmp_path / "scripts" / "install-script"
        script_root.mkdir(parents=True)
        
        # Create realistic test scripts
        basic_dir = script_root / "basic"
        basic_dir.mkdir()
        
        # Successful script
        (basic_dir / "success.sh").write_text("""#!/bin/bash
echo "Starting installation..."
echo "Installing dependencies..."
sleep 0.1
echo "Configuration complete"
exit 0
""")
        
        # Failing script
        (basic_dir / "fail.sh").write_text("""#!/bin/bash
echo "Starting installation..."
echo "Error: Package not found"
exit 1
""")
        
        # Long running script
        (basic_dir / "long.sh").write_text("""#!/bin/bash
echo "Starting long process..."
for i in $(seq 1 5); do
    echo "Step $i of 5"
    sleep 0.05
done
echo "Complete"
exit 0
""")
        
        config_data = {
            "categories": [
                {
                    "id": "base",
                    "name": "基础环境",
                    "icon": "📦",
                    "tools": [
                        {
                            "id": "success-tool",
                            "name": "成功工具",
                            "description": "总是成功的工具",
                            "script": "basic/success.sh",
                            "requires_sudo": False,
                        },
                        {
                            "id": "fail-tool",
                            "name": "失败工具",
                            "description": "总是失败的工具",
                            "script": "basic/fail.sh",
                            "requires_sudo": False,
                        },
                        {
                            "id": "long-tool",
                            "name": "长时工具",
                            "description": "耗时较长的工具",
                            "script": "basic/long.sh",
                            "requires_sudo": False,
                        }
                    ]
                },
                {
                    "id": "dev",
                    "name": "开发工具",
                    "icon": "🔧",
                    "tools": [
                        {
                            "id": "ssh-tool",
                            "name": "SSH工具",
                            "description": "需要SSH的工具",
                            "script": "basic/success.sh",
                            "requires_ssh": True,
                        }
                    ]
                }
            ]
        }
        
        config_file = tmp_path / "config.json"
        config_file.write_text(json.dumps(config_data))
        
        config = Config(config_file, script_root)
        app = Application(config)
        
        return app, script_root

    @pytest.mark.asyncio
    async def test_complete_initialization(self, complete_setup):
        """Test complete app initialization"""
        app, _ = complete_setup
        
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        assert app.state is not None
        assert len(app.state.categories) == 2
        assert len(app.state.all_tools) == 4

    @pytest.mark.asyncio
    async def test_single_tool_installation(self, complete_setup):
        """Test installing a single tool"""
        app, _ = complete_setup
        
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        tool = app.state.all_tools[0]  # success-tool
        await execute_tool(tool, app.state)
        
        assert tool.status == Status.SUCCESS
        assert len(tool.logs) > 0

    @pytest.mark.asyncio
    async def test_failed_tool_installation(self, complete_setup):
        """Test handling of failed installation"""
        app, _ = complete_setup
        
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        tool = app.state.all_tools[1]  # fail-tool
        await execute_tool(tool, app.state)
        
        assert tool.status == Status.FAILED
        log_text = "\n".join(tool.logs)
        assert "失败" in log_text or "Error" in log_text

    @pytest.mark.asyncio
    async def test_ssh_tool_skipped(self, complete_setup):
        """Test SSH-dependent tool skipped when SSH unavailable"""
        app, _ = complete_setup
        
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        app.state.has_ssh = False
        
        # Find SSH tool
        ssh_tool = next(t for t in app.state.all_tools if t.requires_ssh)
        await execute_tool(ssh_tool, app.state)
        
        assert ssh_tool.status == Status.SKIPPED

    @pytest.mark.asyncio
    async def test_batch_installation(self, complete_setup):
        """Test batch installation of multiple tools"""
        app, _ = complete_setup
        
        with patch('tui_installer.app.check_system', new_callable=AsyncMock):
            await app.initialize()
        
        # Select multiple tools
        for tool in app.state.all_tools[:3]:
            tool.selected = True
        
        await install_selected(app.state)
        
        # Check results
        success_count = sum(1 for t in app.state.all_tools[:3] if t.status == Status.SUCCESS)
        failed_count = sum(1 for t in app.state.all_tools[:3] if t.status == Status.FAILED)
        
        assert success_count >= 1
        assert failed_count >= 1  # fail-tool


class TestNavigationWorkflow:
    """Test navigation through the UI"""

    @pytest.fixture
    def nav_state(self, tmp_path: Path) -> AppState:
        """Create state with multiple categories for navigation testing"""
        script_root = tmp_path / "scripts"
        script_root.mkdir()
        
        categories = []
        for cat_idx in range(3):
            tools = []
            for tool_idx in range(4):
                script = script_root / f"tool_{cat_idx}_{tool_idx}.sh"
                script.write_text("#!/bin/bash\nexit 0\n")
                
                data = {
                    "id": f"tool-{cat_idx}-{tool_idx}",
                    "name": f"Tool {cat_idx}.{tool_idx}",
                    "description": f"Description",
                    "script": f"tool_{cat_idx}_{tool_idx}.sh",
                }
                tools.append(Tool(data, f"cat-{cat_idx}", script_root))
            
            cat = Category.__new__(Category)
            cat.id = f"cat-{cat_idx}"
            cat.name = f"Category {cat_idx}"
            cat.icon = "📦"
            cat.tools = tools
            categories.append(cat)
        
        return AppState(categories)

    @pytest.mark.asyncio
    async def test_complete_navigation(self, nav_state: AppState):
        """Test navigating through all categories and tools"""
        # Navigate right through categories
        for _ in range(2):
            await handle_input(nav_state, 'l')
        assert nav_state.current_category_idx == 2
        
        # Navigate down through tools
        for _ in range(3):
            await handle_input(nav_state, 'j')
        assert nav_state.current_tool_idx == 3
        
        # Navigate back
        for _ in range(2):
            await handle_input(nav_state, 'h')
        assert nav_state.current_category_idx == 0
        
        # Tool index should reset on category change
        assert nav_state.current_tool_idx == 0

    @pytest.mark.asyncio
    async def test_selection_across_categories(self, nav_state: AppState):
        """Test selecting tools across categories"""
        # Select tool in first category
        await handle_input(nav_state, ' ')
        
        # Move to second category and select
        await handle_input(nav_state, 'l')
        await handle_input(nav_state, 'j')
        await handle_input(nav_state, ' ')
        
        # Move to third category and select
        await handle_input(nav_state, 'l')
        await handle_input(nav_state, ' ')
        
        selected = nav_state.get_selected_tools()
        assert len(selected) == 3

    @pytest.mark.asyncio
    async def test_view_toggle_workflow(self, nav_state: AppState):
        """Test view toggling during navigation"""
        assert nav_state.view_mode == "list"
        
        # Toggle to logs
        await handle_input(nav_state, '\n')
        assert nav_state.view_mode == "logs"
        
        # Navigation should not work in logs view
        prev_idx = nav_state.current_tool_idx
        await handle_input(nav_state, 'j')
        assert nav_state.current_tool_idx == prev_idx
        
        # Toggle back to list
        await handle_input(nav_state, '\n')
        assert nav_state.view_mode == "list"


class TestConcurrentExecution:
    """Test concurrent tool execution"""

    @pytest.fixture
    def concurrent_setup(self, tmp_path: Path) -> AppState:
        """Create setup for concurrent execution tests"""
        script_root = tmp_path / "scripts"
        script_root.mkdir()
        
        tools = []
        for i in range(5):
            script = script_root / f"concurrent_{i}.sh"
            script.write_text(f"""#!/bin/bash
echo "Tool {i} starting"
sleep 0.1
echo "Tool {i} finished"
exit 0
""")
            script.chmod(0o755)
            
            data = {
                "id": f"tool-{i}",
                "name": f"Concurrent Tool {i}",
                "description": f"Tool {i}",
                "script": f"concurrent_{i}.sh",
            }
            tools.append(Tool(data, "test", script_root))
        
        cat = Category.__new__(Category)
        cat.id = "test"
        cat.name = "Test"
        cat.icon = "🧪"
        cat.tools = tools
        
        state = AppState([cat])
        state.has_sudo = True
        state.has_ssh = True
        return state

    @pytest.mark.asyncio
    async def test_all_tools_complete(self, concurrent_setup: AppState):
        """All concurrent tools should complete"""
        for tool in concurrent_setup.all_tools:
            tool.selected = True
        
        await install_selected(concurrent_setup)
        
        for tool in concurrent_setup.all_tools:
            assert tool.status == Status.SUCCESS

    @pytest.mark.asyncio
    async def test_concurrent_timing(self, concurrent_setup: AppState):
        """Concurrent execution should be faster than sequential"""
        import time
        
        for tool in concurrent_setup.all_tools:
            tool.selected = True
        
        start = time.time()
        await install_selected(concurrent_setup)
        elapsed = time.time() - start
        
        # 5 tools with 0.1s each sequentially = 0.5s
        # Concurrently should be much faster (close to 0.1s)
        # Allow some margin for overhead
        assert elapsed < 0.4, f"Concurrent execution took too long: {elapsed}s"


class TestErrorHandling:
    """Test error handling scenarios"""

    @pytest.fixture
    def error_setup(self, tmp_path: Path) -> AppState:
        """Create setup for error handling tests"""
        script_root = tmp_path / "scripts"
        script_root.mkdir()
        
        tools = []
        
        # Missing script
        data = {
            "id": "missing",
            "name": "Missing Script",
            "description": "Script doesn't exist",
            "script": "nonexistent.sh",
        }
        tools.append(Tool(data, "test", script_root))
        
        # Script with runtime error (set -e ensures error propagates)
        error_script = script_root / "error.sh"
        error_script.write_text("#!/bin/bash\nset -e\nundefined_command\necho 'should not reach here'\n")
        error_script.chmod(0o755)
        
        data = {
            "id": "error",
            "name": "Error Script",
            "description": "Script with errors",
            "script": "error.sh",
        }
        tools.append(Tool(data, "test", script_root))
        
        cat = Category.__new__(Category)
        cat.id = "test"
        cat.name = "Test"
        cat.icon = "🧪"
        cat.tools = tools
        
        return AppState([cat])

    @pytest.mark.asyncio
    async def test_missing_script_handled(self, error_setup: AppState):
        """Missing script should fail gracefully"""
        tool = error_setup.all_tools[0]
        await execute_tool(tool, error_setup)
        
        assert tool.status == Status.FAILED
        assert error_setup.active_tasks == 0

    @pytest.mark.asyncio
    async def test_runtime_error_handled(self, error_setup: AppState):
        """Script runtime errors should be handled"""
        tool = error_setup.all_tools[1]
        await execute_tool(tool, error_setup)
        
        assert tool.status == Status.FAILED


class TestConfigurationLoading:
    """Test configuration file loading"""

    def test_load_bundled_config(self):
        """Should load bundled tools_config.json"""
        from tui_installer.config import DATA_DIR
        
        config_file = DATA_DIR / "tools_config.json"
        assert config_file.exists()
        
        with open(config_file) as f:
            data = json.load(f)
        
        assert "categories" in data
        assert len(data["categories"]) > 0
        
        # Verify structure
        for cat in data["categories"]:
            assert "id" in cat
            assert "name" in cat
            assert "tools" in cat
            for tool in cat["tools"]:
                assert "id" in tool
                assert "name" in tool
                assert "script" in tool

    def test_config_validation(self, tmp_path: Path):
        """Should validate required fields"""
        # Missing required field
        bad_config = {"categories": [{"id": "test"}]}
        config_file = tmp_path / "bad.json"
        config_file.write_text(json.dumps(bad_config))
        
        config = Config(config_file, tmp_path)
        
        # Should raise on load when accessing missing fields
        with pytest.raises((KeyError, TypeError)):
            config.load()


class TestStateConsistency:
    """Test state consistency across operations"""

    @pytest.fixture
    def consistency_state(self, tmp_path: Path) -> AppState:
        """Create state for consistency tests"""
        script_root = tmp_path / "scripts"
        script_root.mkdir()
        
        script = script_root / "test.sh"
        script.write_text("#!/bin/bash\nexit 0\n")
        script.chmod(0o755)
        
        tools = [
            Tool({"id": f"t{i}", "name": f"T{i}", "description": "D", "script": "test.sh"}, "cat", script_root)
            for i in range(3)
        ]
        
        cat = Category.__new__(Category)
        cat.id = "cat"
        cat.name = "Category"
        cat.icon = "📦"
        cat.tools = tools
        
        return AppState([cat])

    @pytest.mark.asyncio
    async def test_active_tasks_consistency(self, consistency_state: AppState):
        """Active tasks counter should remain consistent"""
        assert consistency_state.active_tasks == 0
        
        for tool in consistency_state.all_tools:
            tool.selected = True
        
        await install_selected(consistency_state)
        
        assert consistency_state.active_tasks == 0

    @pytest.mark.asyncio
    async def test_selection_preserved(self, consistency_state: AppState):
        """Selection state should be preserved after operations"""
        consistency_state.all_tools[0].selected = True
        consistency_state.all_tools[2].selected = True
        
        # Navigate
        await handle_input(consistency_state, 'j')
        await handle_input(consistency_state, 'k')
        
        # Selection should be preserved
        assert consistency_state.all_tools[0].selected is True
        assert consistency_state.all_tools[1].selected is False
        assert consistency_state.all_tools[2].selected is True

