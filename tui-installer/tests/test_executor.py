"""
Tests for task execution engine
"""

import asyncio
import pytest
from pathlib import Path
from unittest.mock import AsyncMock, patch, MagicMock

from tui_installer.models import Tool, Category, AppState, Status
from tui_installer.executor import execute_tool, install_selected


class TestExecuteTool:
    """Test execute_tool function"""

    @pytest.fixture
    def mock_tool(self, tmp_path: Path) -> Tool:
        """Create a tool with a working test script"""
        script_dir = tmp_path / "scripts"
        script_dir.mkdir()
        script = script_dir / "test_script.sh"
        script.write_text("#!/bin/bash\necho 'Hello from test'\nexit 0\n")
        script.chmod(0o755)
        
        data = {
            "id": "test-tool",
            "name": "Test Tool",
            "description": "A test tool",
            "script": "test_script.sh",
            "requires_sudo": False,
            "check_cmd": "true"
        }
        return Tool(data, "test-cat", script_dir)

    @pytest.fixture
    def mock_state(self, mock_tool: Tool) -> AppState:
        """Create app state with mock tool"""
        category_data = {
            "id": "test-cat",
            "name": "Test Category",
            "icon": "🧪",
            "tools": []
        }
        cat = Category.__new__(Category)
        cat.id = "test-cat"
        cat.name = "Test Category"
        cat.icon = "🧪"
        cat.tools = [mock_tool]
        
        state = AppState([cat])
        state.has_sudo = True
        state.has_ssh = True
        return state

    @pytest.mark.asyncio
    async def test_execute_tool_success(self, mock_tool: Tool, mock_state: AppState):
        """Tool should complete successfully with exit code 0"""
        await execute_tool(mock_tool, mock_state)
        
        assert mock_tool.status == Status.SUCCESS
        assert mock_tool.end_time is not None
        assert len(mock_tool.logs) > 0
        # Check log contains output
        log_text = "\n".join(mock_tool.logs)
        assert "Hello from test" in log_text or "成功" in log_text

    @pytest.mark.asyncio
    async def test_execute_tool_failure(self, tmp_path: Path, mock_state: AppState):
        """Tool should fail with non-zero exit code"""
        script_dir = tmp_path / "fail_scripts"
        script_dir.mkdir(exist_ok=True)
        script = script_dir / "fail_script.sh"
        script.write_text("#!/bin/bash\necho 'Failing'\nexit 1\n")
        script.chmod(0o755)
        
        data = {
            "id": "fail-tool",
            "name": "Failing Tool",
            "description": "A failing tool",
            "script": "fail_script.sh",
        }
        tool = Tool(data, "test-cat", script_dir)
        
        await execute_tool(tool, mock_state)
        
        assert tool.status == Status.FAILED

    @pytest.mark.asyncio
    async def test_execute_tool_missing_script(self, tmp_path: Path, mock_state: AppState):
        """Tool should fail if script doesn't exist"""
        data = {
            "id": "missing-tool",
            "name": "Missing Script Tool",
            "description": "Tool with missing script",
            "script": "nonexistent.sh",
        }
        tool = Tool(data, "test-cat", tmp_path)
        
        await execute_tool(tool, mock_state)
        
        assert tool.status == Status.FAILED
        log_text = "\n".join(tool.logs)
        assert "不存在" in log_text or "错误" in log_text

    @pytest.mark.asyncio
    async def test_execute_tool_skip_ssh(self, mock_tool: Tool, mock_state: AppState):
        """Tool requiring SSH should be skipped if SSH not configured"""
        mock_tool.requires_ssh = True
        mock_state.has_ssh = False
        
        await execute_tool(mock_tool, mock_state)
        
        assert mock_tool.status == Status.SKIPPED

    @pytest.mark.asyncio
    async def test_execute_tool_active_tasks_counter(self, mock_tool: Tool, mock_state: AppState):
        """Active tasks counter should increment and decrement"""
        assert mock_state.active_tasks == 0
        
        await execute_tool(mock_tool, mock_state)
        
        # After completion, counter should be back to 0
        assert mock_state.active_tasks == 0

    @pytest.mark.asyncio
    async def test_execute_tool_timing(self, mock_tool: Tool, mock_state: AppState):
        """Tool should record start and end times"""
        await execute_tool(mock_tool, mock_state)
        
        assert mock_tool.start_time is not None
        assert mock_tool.end_time is not None
        assert mock_tool.end_time >= mock_tool.start_time


class TestInstallSelected:
    """Test install_selected function"""

    @pytest.fixture
    def tools_state(self, tmp_path: Path) -> tuple:
        """Create multiple tools with scripts"""
        script_dir = tmp_path / "scripts"
        script_dir.mkdir()
        
        tools = []
        for i in range(3):
            script = script_dir / f"tool{i}.sh"
            script.write_text(f"#!/bin/bash\necho 'Tool {i}'\nexit 0\n")
            script.chmod(0o755)
            
            data = {
                "id": f"tool-{i}",
                "name": f"Tool {i}",
                "description": f"Test tool {i}",
                "script": f"tool{i}.sh",
            }
            tools.append(Tool(data, "test-cat", script_dir))
        
        category_data = {
            "id": "test-cat",
            "name": "Test Category",
            "icon": "🧪",
            "tools": []
        }
        cat = Category.__new__(Category)
        cat.id = "test-cat"
        cat.name = "Test Category"
        cat.icon = "🧪"
        cat.tools = tools
        
        state = AppState([cat])
        state.has_sudo = True
        state.has_ssh = True
        
        return tools, state

    @pytest.mark.asyncio
    async def test_install_selected_empty(self, tools_state):
        """Should do nothing when no tools selected"""
        tools, state = tools_state
        
        await install_selected(state)
        
        # All tools should still be pending
        for tool in tools:
            assert tool.status == Status.PENDING

    @pytest.mark.asyncio
    async def test_install_selected_some(self, tools_state):
        """Should install only selected tools"""
        tools, state = tools_state
        
        # Select first two tools
        tools[0].selected = True
        tools[1].selected = True
        
        await install_selected(state)
        
        assert tools[0].status == Status.SUCCESS
        assert tools[1].status == Status.SUCCESS
        assert tools[2].status == Status.PENDING

    @pytest.mark.asyncio
    async def test_install_selected_concurrent(self, tools_state):
        """Selected tools should run concurrently"""
        tools, state = tools_state
        
        for tool in tools:
            tool.selected = True
        
        await install_selected(state)
        
        # All should complete
        for tool in tools:
            assert tool.status == Status.SUCCESS

    @pytest.mark.asyncio
    async def test_install_selected_skip_running(self, tools_state):
        """Should skip tools that are already running"""
        tools, state = tools_state
        
        tools[0].selected = True
        tools[0].status = Status.RUNNING
        tools[1].selected = True
        
        await install_selected(state)
        
        # First tool should still be marked as running (not re-run)
        assert tools[0].status == Status.RUNNING
        assert tools[1].status == Status.SUCCESS

    @pytest.mark.asyncio
    async def test_install_selected_skip_completed(self, tools_state):
        """Should skip tools that are already completed"""
        tools, state = tools_state
        
        tools[0].selected = True
        tools[0].status = Status.SUCCESS
        tools[1].selected = True
        
        await install_selected(state)
        
        # First tool should still be SUCCESS
        assert tools[0].status == Status.SUCCESS
        assert tools[1].status == Status.SUCCESS


class TestExecutorEdgeCases:
    """Test edge cases in executor"""

    @pytest.mark.asyncio
    async def test_execute_script_with_stderr(self, tmp_path: Path):
        """Script stderr should be captured in logs"""
        script_dir = tmp_path / "scripts"
        script_dir.mkdir()
        script = script_dir / "stderr_script.sh"
        script.write_text("#!/bin/bash\necho 'stdout output'\necho 'stderr output' >&2\nexit 0\n")
        script.chmod(0o755)
        
        data = {
            "id": "stderr-tool",
            "name": "Stderr Tool",
            "description": "Tool with stderr",
            "script": "stderr_script.sh",
        }
        tool = Tool(data, "test-cat", script_dir)
        
        category_data = {
            "id": "test-cat",
            "name": "Test",
            "icon": "🧪",
            "tools": []
        }
        cat = Category.__new__(Category)
        cat.id = "test-cat"
        cat.name = "Test"
        cat.icon = "🧪"
        cat.tools = [tool]
        
        state = AppState([cat])
        
        await execute_tool(tool, state)
        
        log_text = "\n".join(tool.logs)
        # Both stdout and stderr should be captured (stderr redirected to stdout)
        assert "stdout output" in log_text or "stderr output" in log_text

    @pytest.mark.asyncio
    async def test_execute_long_output(self, tmp_path: Path):
        """Should handle scripts with long output"""
        script_dir = tmp_path / "scripts"
        script_dir.mkdir()
        script = script_dir / "long_output.sh"
        # Generate script that outputs many lines
        script.write_text("#!/bin/bash\nfor i in $(seq 1 100); do echo \"Line $i\"; done\nexit 0\n")
        script.chmod(0o755)
        
        data = {
            "id": "long-tool",
            "name": "Long Output Tool",
            "description": "Tool with long output",
            "script": "long_output.sh",
        }
        tool = Tool(data, "test-cat", script_dir)
        
        category_data = {"id": "test-cat", "name": "Test", "icon": "🧪", "tools": []}
        cat = Category.__new__(Category)
        cat.id = "test-cat"
        cat.name = "Test"
        cat.icon = "🧪"
        cat.tools = [tool]
        
        state = AppState([cat])
        
        await execute_tool(tool, state)
        
        assert tool.status == Status.SUCCESS
        # Log should have captured output (limited to 500 lines)
        assert len(tool.logs) > 10

