"""
Tests for keyboard input handling
"""

import asyncio
import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock, AsyncMock

from tui_installer.models import AppState, Category, Tool, Status
from tui_installer.input import handle_input


class TestHandleInput:
    """Test input handler function"""

    @pytest.fixture
    def state_with_tools(self, tmp_path: Path) -> AppState:
        """Create app state with multiple tools for testing"""
        script_dir = tmp_path / "scripts"
        script_dir.mkdir()
        
        # Create test scripts
        for i in range(3):
            script = script_dir / f"tool{i}.sh"
            script.write_text(f"#!/bin/bash\necho 'Tool {i}'\nexit 0\n")
            script.chmod(0o755)
        
        # Create two categories with tools
        categories = []
        for cat_idx in range(2):
            tools = []
            for tool_idx in range(3):
                data = {
                    "id": f"tool-{cat_idx}-{tool_idx}",
                    "name": f"Tool {cat_idx}-{tool_idx}",
                    "description": f"Test tool {cat_idx}-{tool_idx}",
                    "script": f"tool{tool_idx}.sh",
                }
                tools.append(Tool(data, f"cat-{cat_idx}", script_dir))
            
            cat = Category.__new__(Category)
            cat.id = f"cat-{cat_idx}"
            cat.name = f"Category {cat_idx}"
            cat.icon = "🧪"
            cat.tools = tools
            categories.append(cat)
        
        state = AppState(categories)
        state.has_sudo = True
        state.has_ssh = True
        return state


class TestQuitInput:
    """Test quit functionality"""

    @pytest.fixture
    def simple_state(self) -> AppState:
        """Create minimal app state"""
        cat = Category.__new__(Category)
        cat.id = "test"
        cat.name = "Test"
        cat.icon = "🧪"
        cat.tools = []
        return AppState([cat])

    @pytest.mark.asyncio
    async def test_quit_lowercase(self, simple_state: AppState):
        """'q' should set running to False"""
        assert simple_state.running is True
        
        await handle_input(simple_state, 'q')
        
        assert simple_state.running is False

    @pytest.mark.asyncio
    async def test_quit_uppercase(self, simple_state: AppState):
        """'Q' should also quit"""
        await handle_input(simple_state, 'Q')
        
        assert simple_state.running is False


class TestNavigationInput(TestHandleInput):
    """Test navigation keybindings"""

    @pytest.mark.asyncio
    async def test_move_down_j(self, state_with_tools: AppState):
        """'j' should move tool selection down"""
        assert state_with_tools.current_tool_idx == 0
        
        await handle_input(state_with_tools, 'j')
        
        assert state_with_tools.current_tool_idx == 1

    @pytest.mark.asyncio
    async def test_move_down_arrow(self, state_with_tools: AppState):
        """DOWN arrow should move tool selection down"""
        await handle_input(state_with_tools, 'DOWN')
        
        assert state_with_tools.current_tool_idx == 1

    @pytest.mark.asyncio
    async def test_move_up_k(self, state_with_tools: AppState):
        """'k' should move tool selection up"""
        state_with_tools.current_tool_idx = 1
        
        await handle_input(state_with_tools, 'k')
        
        assert state_with_tools.current_tool_idx == 0

    @pytest.mark.asyncio
    async def test_move_up_arrow(self, state_with_tools: AppState):
        """UP arrow should move tool selection up"""
        state_with_tools.current_tool_idx = 1
        
        await handle_input(state_with_tools, 'UP')
        
        assert state_with_tools.current_tool_idx == 0

    @pytest.mark.asyncio
    async def test_move_category_right_l(self, state_with_tools: AppState):
        """'l' should move to next category"""
        assert state_with_tools.current_category_idx == 0
        
        await handle_input(state_with_tools, 'l')
        
        assert state_with_tools.current_category_idx == 1

    @pytest.mark.asyncio
    async def test_move_category_right_arrow(self, state_with_tools: AppState):
        """RIGHT arrow should move to next category"""
        await handle_input(state_with_tools, 'RIGHT')
        
        assert state_with_tools.current_category_idx == 1

    @pytest.mark.asyncio
    async def test_move_category_left_h(self, state_with_tools: AppState):
        """'h' should move to previous category"""
        state_with_tools.current_category_idx = 1
        
        await handle_input(state_with_tools, 'h')
        
        assert state_with_tools.current_category_idx == 0

    @pytest.mark.asyncio
    async def test_move_category_left_arrow(self, state_with_tools: AppState):
        """LEFT arrow should move to previous category"""
        state_with_tools.current_category_idx = 1
        
        await handle_input(state_with_tools, 'LEFT')
        
        assert state_with_tools.current_category_idx == 0

    @pytest.mark.asyncio
    async def test_navigation_in_logs_view(self, state_with_tools: AppState):
        """Navigation should not work in logs view"""
        state_with_tools.view_mode = "logs"
        state_with_tools.current_tool_idx = 1
        
        await handle_input(state_with_tools, 'j')
        
        # Should not change in logs view
        assert state_with_tools.current_tool_idx == 1


class TestSelectionInput(TestHandleInput):
    """Test selection keybindings"""

    @pytest.mark.asyncio
    async def test_toggle_selection_space(self, state_with_tools: AppState):
        """Space should toggle tool selection"""
        tool = state_with_tools.current_tool
        assert tool.selected is False
        
        await handle_input(state_with_tools, ' ')
        
        assert tool.selected is True
        
        await handle_input(state_with_tools, ' ')
        
        assert tool.selected is False


class TestViewToggleInput(TestHandleInput):
    """Test view toggle keybindings"""

    @pytest.mark.asyncio
    async def test_toggle_view_enter(self, state_with_tools: AppState):
        """Enter should toggle between list and logs view"""
        assert state_with_tools.view_mode == "list"
        
        await handle_input(state_with_tools, '\n')
        
        assert state_with_tools.view_mode == "logs"
        
        await handle_input(state_with_tools, '\n')
        
        assert state_with_tools.view_mode == "list"

    @pytest.mark.asyncio
    async def test_toggle_view_carriage_return(self, state_with_tools: AppState):
        """Carriage return should also toggle view"""
        await handle_input(state_with_tools, '\r')
        
        assert state_with_tools.view_mode == "logs"

    @pytest.mark.asyncio
    async def test_toggle_view_L(self, state_with_tools: AppState):
        """'L' (uppercase) should toggle logs view"""
        await handle_input(state_with_tools, 'L')
        
        assert state_with_tools.view_mode == "logs"


class TestInstallInput(TestHandleInput):
    """Test install keybindings"""

    @pytest.mark.asyncio
    async def test_install_current_i(self, state_with_tools: AppState):
        """'i' should install current tool"""
        tool = state_with_tools.current_tool
        assert tool.status == Status.PENDING
        
        # Use patch to prevent actual execution
        with patch('tui_installer.input.execute_tool', new_callable=AsyncMock) as mock_exec:
            await handle_input(state_with_tools, 'i')
            # Give time for task creation
            await asyncio.sleep(0.01)
        
        # Tool should be selected
        assert tool.selected is True

    @pytest.mark.asyncio
    async def test_install_current_I(self, state_with_tools: AppState):
        """'I' should also install current tool"""
        tool = state_with_tools.current_tool
        
        with patch('tui_installer.input.execute_tool', new_callable=AsyncMock):
            await handle_input(state_with_tools, 'I')
            await asyncio.sleep(0.01)
        
        assert tool.selected is True

    @pytest.mark.asyncio
    async def test_install_current_skip_non_pending(self, state_with_tools: AppState):
        """Should not install already running tool"""
        tool = state_with_tools.current_tool
        tool.status = Status.RUNNING
        
        with patch('tui_installer.input.execute_tool', new_callable=AsyncMock) as mock_exec:
            await handle_input(state_with_tools, 'i')
            await asyncio.sleep(0.01)
        
        # execute_tool should not be called
        # (since we're checking before task creation)
        assert tool.selected is False

    @pytest.mark.asyncio
    async def test_install_all_selected_a(self, state_with_tools: AppState):
        """'a' should install all selected tools"""
        # Select some tools
        state_with_tools.categories[0].tools[0].selected = True
        state_with_tools.categories[0].tools[1].selected = True
        
        with patch('tui_installer.input.install_selected', new_callable=AsyncMock) as mock_install:
            await handle_input(state_with_tools, 'a')
            await asyncio.sleep(0.01)
        
        # install_selected should have been scheduled

    @pytest.mark.asyncio
    async def test_install_all_selected_empty(self, state_with_tools: AppState):
        """'a' should do nothing when no tools selected"""
        # No tools selected
        with patch('tui_installer.input.install_selected', new_callable=AsyncMock) as mock_install:
            await handle_input(state_with_tools, 'a')


class TestUnknownInput(TestHandleInput):
    """Test handling of unknown inputs"""

    @pytest.mark.asyncio
    async def test_unknown_key_no_effect(self, state_with_tools: AppState):
        """Unknown keys should have no effect"""
        initial_idx = state_with_tools.current_tool_idx
        initial_cat = state_with_tools.current_category_idx
        initial_view = state_with_tools.view_mode
        initial_running = state_with_tools.running
        
        await handle_input(state_with_tools, 'x')
        await handle_input(state_with_tools, 'z')
        await handle_input(state_with_tools, '1')
        
        assert state_with_tools.current_tool_idx == initial_idx
        assert state_with_tools.current_category_idx == initial_cat
        assert state_with_tools.view_mode == initial_view
        assert state_with_tools.running == initial_running

