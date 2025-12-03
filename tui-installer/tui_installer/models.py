"""
Data models for the TUI installer
"""

from __future__ import annotations
from collections import deque
from datetime import datetime
from enum import Enum, auto
from pathlib import Path
from typing import List, Dict, Optional, Deque, TYPE_CHECKING

if TYPE_CHECKING:
    from .system import SystemInfo


class Status(Enum):
    """Task execution status"""
    PENDING = auto()      # 待装：未检测到，无成功安装记录
    RUNNING = auto()      # 运行中：正在安装
    SUCCESS = auto()      # 成功：本次会话刚安装成功
    FAILED = auto()       # 失败：安装失败
    SKIPPED = auto()      # 跳过：因条件不满足跳过
    INSTALLED = auto()    # 已装：启动时检测到已安装
    BROKEN = auto()       # 异常：有成功记录但检测失败（可能被卸载）


# Status icons with absolute hex colors (not affected by terminal themes)
# Format: (icon, color_hex, label)
STATUS_ICONS = {
    Status.PENDING: ("⚪", "#6c7086", "待装"),     # Overlay0 - dimmed
    Status.RUNNING: ("🔵", "#89b4fa", "运行"),     # Blue
    Status.SUCCESS: ("🟢", "#a6e3a1", "完成"),     # Green
    Status.FAILED: ("🔴", "#f38ba8", "失败"),      # Red
    Status.SKIPPED: ("⚫", "#7f849c", "跳过"),     # Overlay1 - dimmed
    Status.INSTALLED: ("✅", "#94e2d5", "已装"),   # Teal - installed
    Status.BROKEN: ("⚠️", "#fab387", "异常"),      # Peach - warning
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
        
        # Cache for script content preview
        self._script_cache: Optional[str] = None
        self._script_cache_lines: int = 0
        
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
    
    def get_script_content(self, max_lines: int = 30) -> str:
        """Read and return script content for preview (cached)"""
        # Return cached content if available and max_lines matches
        if self._script_cache is not None and self._script_cache_lines == max_lines:
            return self._script_cache
        
        if not self.script_path.exists():
            result = f"脚本文件不存在: {self.script_rel}"
            self._script_cache = result
            self._script_cache_lines = max_lines
            return result
        
        try:
            content = self.script_path.read_text(encoding="utf-8")
            lines = content.splitlines()
            
            if len(lines) > max_lines:
                preview_lines = lines[:max_lines]
                preview_lines.append(f"... 共 {len(lines)} 行，省略 {len(lines) - max_lines} 行 ...")
                result = "\n".join(preview_lines)
            else:
                result = content
            
            # Cache the result
            self._script_cache = result
            self._script_cache_lines = max_lines
            return result
        except Exception as e:
            return f"读取脚本失败: {e}"
    
    def apply_verified_status(self, status_str: str) -> None:
        """
        Apply verified status from state manager.
        
        Args:
            status_str: One of "installed", "broken", "pending"
        """
        if status_str == "installed":
            self.status = Status.INSTALLED
        elif status_str == "broken":
            self.status = Status.BROKEN
        else:
            self.status = Status.PENDING
    
    @property
    def is_installable(self) -> bool:
        """Check if tool can be installed (not already running or completed)."""
        return self.status in (Status.PENDING, Status.BROKEN, Status.FAILED)


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
        
        # System info (detailed, populated by check_system)
        self.system_info: Optional[SystemInfo] = None
        
        # Legacy system flags (kept for backward compatibility)
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


