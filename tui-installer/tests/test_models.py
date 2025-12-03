"""
Tests for data models
"""

import pytest
from pathlib import Path

from tui_installer.models import Tool, Category, AppState, Status, STATUS_ICONS


class TestStatus:
    """Test Status enum"""
    
    def test_all_statuses_have_icons(self):
        """Every status should have an icon defined"""
        for status in Status:
            assert status in STATUS_ICONS
            icon, color, text = STATUS_ICONS[status]
            assert icon
            assert color
            assert text


class TestTool:
    """Test Tool model"""
    
    def test_tool_creation(self, temp_script_root: Path):
        """Tool should be created with correct attributes"""
        data = {
            "id": "test-tool",
            "name": "测试工具",
            "description": "一个测试用工具",
            "script": "test/script.sh",
            "requires_sudo": True,
            "check_cmd": "command -v test"
        }
        tool = Tool(data, "test-category", temp_script_root)
        
        assert tool.id == "test-tool"
        assert tool.name == "测试工具"
        assert tool.description == "一个测试用工具"
        assert tool.requires_sudo is True
        assert tool.category_id == "test-category"
        assert tool.status == Status.PENDING
        assert tool.selected is False
    
    def test_tool_add_log(self, temp_script_root: Path):
        """Tool should store log entries with timestamps"""
        data = {
            "id": "test",
            "name": "Test",
            "description": "Test",
            "script": "test.sh",
        }
        tool = Tool(data, "cat", temp_script_root)
        
        tool.add_log("第一条日志")
        tool.add_log("第二条日志")
        
        assert len(tool.logs) == 2
        assert "第一条日志" in tool.logs[0]
        assert "第二条日志" in tool.logs[1]


class TestCategory:
    """Test Category model"""
    
    def test_category_creation(self, temp_script_root: Path):
        """Category should contain tools"""
        data = {
            "id": "dev",
            "name": "开发工具",
            "icon": "🔧",
            "tools": [
                {"id": "t1", "name": "Tool 1", "description": "D1", "script": "s1.sh"},
                {"id": "t2", "name": "Tool 2", "description": "D2", "script": "s2.sh"},
            ]
        }
        cat = Category(data, temp_script_root)
        
        assert cat.id == "dev"
        assert cat.name == "开发工具"
        assert cat.icon == "🔧"
        assert len(cat.tools) == 2


class TestAppState:
    """Test AppState model"""
    
    def test_navigation(self, app_state: AppState):
        """AppState should handle navigation correctly"""
        # Initial state
        assert app_state.current_category_idx == 0
        assert app_state.current_tool_idx == 0
        
        # Move down
        app_state.move_tool(1)
        assert app_state.current_tool_idx == 1
        
        # Move up
        app_state.move_tool(-1)
        assert app_state.current_tool_idx == 0
        
        # Move to next category
        app_state.move_category(1)
        assert app_state.current_category_idx == 1
        assert app_state.current_tool_idx == 0  # Reset on category change
    
    def test_selection(self, app_state: AppState):
        """AppState should handle tool selection"""
        tool = app_state.current_tool
        assert tool is not None
        assert tool.selected is False
        
        app_state.toggle_selection()
        assert tool.selected is True
        
        app_state.toggle_selection()
        assert tool.selected is False
    
    def test_get_selected_tools(self, app_state: AppState):
        """AppState should return selected tools"""
        # Select first tool
        app_state.toggle_selection()
        
        # Move to second tool and select
        app_state.move_tool(1)
        app_state.toggle_selection()
        
        selected = app_state.get_selected_tools()
        assert len(selected) == 2
    
    def test_boundary_navigation(self, app_state: AppState):
        """Navigation should not go out of bounds"""
        # Try to go before first
        app_state.move_tool(-1)
        assert app_state.current_tool_idx == 0
        
        app_state.move_category(-1)
        assert app_state.current_category_idx == 0

