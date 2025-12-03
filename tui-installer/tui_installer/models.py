"""
Data models for the TUI installer
"""

from collections import deque
from datetime import datetime
from enum import Enum, auto
from pathlib import Path
from typing import List, Dict, Optional, Deque


class Status(Enum):
    """Task execution status"""
    PENDING = auto()
    RUNNING = auto()
    SUCCESS = auto()
    FAILED = auto()
    SKIPPED = auto()


STATUS_ICONS = {
    Status.PENDING: ("⚪", "dim white", "待装"),
    Status.RUNNING: ("🔵", "bold blue", "运行"),
    Status.SUCCESS: ("🟢", "bold green", "完成"),
    Status.FAILED: ("🔴", "bold red", "失败"),
    Status.SKIPPED: ("⚫", "dim", "跳过"),
}


class Tool:
    """Represents an installable tool/package"""
    
    def __init__(self, data: dict, category_id: str, script_root: Path):
        self.id = data["id"]
        self.name = data["name"]
        self.description = data["description"]
        self.script_rel = data["script"]
        self.script_path = script_root / self.script_rel
        self.requires_sudo = data.get("requires_sudo", False)
        self.requires_ssh = data.get("requires_ssh", False)
        self.check_cmd = data.get("check_cmd", "")
        self.category_id = category_id
        
        self.status = Status.PENDING
        self.selected = False
        self.logs: Deque[str] = deque(maxlen=500)
        self.start_time: Optional[float] = None
        self.end_time: Optional[float] = None
        
    @property
    def elapsed_time(self) -> str:
        """Get formatted elapsed time"""
        if not self.start_time:
            return ""
        end = self.end_time or datetime.now().timestamp()
        delta = end - self.start_time
        if delta < 60:
            return f"{delta:.1f}s"
        return f"{delta/60:.1f}m"
    
    def add_log(self, line: str):
        """Add log line with timestamp"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.logs.append(f"[{timestamp}] {line}")


class Category:
    """Represents a category of tools"""
    
    def __init__(self, data: dict, script_root: Path):
        self.id = data["id"]
        self.name = data["name"]
        self.icon = data.get("icon", "📦")
        self.tools: List[Tool] = [
            Tool(tool_data, self.id, script_root) 
            for tool_data in data.get("tools", [])
        ]


class AppState:
    """Global application state"""
    
    def __init__(self, categories: List[Category]):
        self.categories = categories
        self.current_category_idx = 0
        self.current_tool_idx = 0
        self.view_mode = "list"  # list, logs
        self.running = True
        self.active_tasks = 0
        self.focus_panel = "sidebar"  # sidebar, body - 当前焦点所在的边栏
        
        # System info
        self.has_sudo = False
        self.has_ssh = False
        self.is_wsl = False
        
    @property
    def current_category(self) -> Category:
        """Get currently selected category"""
        return self.categories[self.current_category_idx]
    
    @property
    def current_tool(self) -> Optional[Tool]:
        """Get currently selected tool"""
        tools = self.current_category.tools
        if 0 <= self.current_tool_idx < len(tools):
            return tools[self.current_tool_idx]
        return None
    
    @property
    def all_tools(self) -> List[Tool]:
        """Get all tools from all categories"""
        tools = []
        for cat in self.categories:
            tools.extend(cat.tools)
        return tools
    
    def move_category(self, delta: int):
        """Move category selection"""
        new_idx = self.current_category_idx + delta
        if 0 <= new_idx < len(self.categories):
            self.current_category_idx = new_idx
            self.current_tool_idx = 0  # Reset tool selection
    
    def move_tool(self, delta: int):
        """Move tool selection within current category"""
        tools = self.current_category.tools
        new_idx = self.current_tool_idx + delta
        if 0 <= new_idx < len(tools):
            self.current_tool_idx = new_idx
    
    def toggle_selection(self):
        """Toggle current tool selection"""
        if tool := self.current_tool:
            tool.selected = not tool.selected
    
    def get_selected_tools(self) -> List[Tool]:
        """Get all selected tools"""
        return [t for t in self.all_tools if t.selected]


