"""
Installation state management with dual verification.

Provides persistent local state tracking combined with real-time
detection for reliable installation status determination.

State file location: ~/.local/share/tui-installer/state.json
This file is NOT tracked by git (local to each machine).
"""

from __future__ import annotations

import asyncio
import json
import subprocess
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from .models import Tool, AppState


# State file location (XDG Base Directory compliant)
STATE_DIR = Path.home() / ".local" / "share" / "tui-installer"
STATE_FILE = STATE_DIR / "state.json"

# Current state file schema version
STATE_VERSION = 1


@dataclass
class InstallRecord:
    """Record of a single tool installation."""
    tool_id: str
    installed_at: str  # ISO format datetime
    success: bool
    version: str = ""
    last_check_at: str = ""
    last_check_passed: bool = False
    
    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return asdict(self)
    
    @classmethod
    def from_dict(cls, data: dict) -> "InstallRecord":
        """Create from dictionary."""
        return cls(
            tool_id=data.get("tool_id", ""),
            installed_at=data.get("installed_at", ""),
            success=data.get("success", False),
            version=data.get("version", ""),
            last_check_at=data.get("last_check_at", ""),
            last_check_passed=data.get("last_check_passed", False),
        )


@dataclass
class StateData:
    """Complete state file data structure."""
    version: int = STATE_VERSION
    tools: Dict[str, InstallRecord] = field(default_factory=dict)
    
    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "version": self.version,
            "tools": {k: v.to_dict() for k, v in self.tools.items()}
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> "StateData":
        """Create from dictionary with migration support."""
        version = data.get("version", 1)
        tools_data = data.get("tools", {})
        
        tools = {}
        for tool_id, record_data in tools_data.items():
            if isinstance(record_data, dict):
                record_data["tool_id"] = tool_id  # Ensure tool_id is set
                tools[tool_id] = InstallRecord.from_dict(record_data)
        
        return cls(version=version, tools=tools)


class StateManager:
    """
    Manages installation state with dual verification.
    
    Features:
    - Persistent state file at ~/.local/share/tui-installer/state.json
    - Real-time tool detection via check_cmd
    - Intelligent state merging and verification
    """
    
    def __init__(self):
        self._data: StateData = StateData()
        self._loaded: bool = False
    
    def _ensure_dir(self) -> None:
        """Ensure state directory exists."""
        STATE_DIR.mkdir(parents=True, exist_ok=True)
    
    def load(self) -> None:
        """Load state from disk."""
        if self._loaded:
            return
        
        try:
            if STATE_FILE.exists():
                with open(STATE_FILE, "r", encoding="utf-8") as f:
                    data = json.load(f)
                self._data = StateData.from_dict(data)
        except (json.JSONDecodeError, IOError, KeyError) as e:
            # Corrupted or unreadable state file, start fresh
            self._data = StateData()
        
        self._loaded = True
    
    def save(self) -> None:
        """Save state to disk."""
        self._ensure_dir()
        try:
            with open(STATE_FILE, "w", encoding="utf-8") as f:
                json.dump(self._data.to_dict(), f, indent=2, ensure_ascii=False)
        except IOError as e:
            # Log error but don't crash
            pass
    
    def get_record(self, tool_id: str) -> Optional[InstallRecord]:
        """Get installation record for a tool."""
        self.load()
        return self._data.tools.get(tool_id)
    
    def has_successful_record(self, tool_id: str) -> bool:
        """Check if tool has a successful installation record."""
        record = self.get_record(tool_id)
        return record is not None and record.success
    
    def record_install(
        self, 
        tool_id: str, 
        success: bool, 
        version: str = ""
    ) -> None:
        """Record an installation attempt."""
        self.load()
        
        now = datetime.now().isoformat()
        record = InstallRecord(
            tool_id=tool_id,
            installed_at=now,
            success=success,
            version=version,
            last_check_at=now,
            last_check_passed=success,
        )
        
        self._data.tools[tool_id] = record
        self.save()
    
    def update_check_result(
        self, 
        tool_id: str, 
        passed: bool
    ) -> None:
        """Update the last check result for a tool."""
        self.load()
        
        now = datetime.now().isoformat()
        record = self._data.tools.get(tool_id)
        
        if record:
            record.last_check_at = now
            record.last_check_passed = passed
            self.save()
    
    def clear_record(self, tool_id: str) -> None:
        """Remove installation record for a tool."""
        self.load()
        if tool_id in self._data.tools:
            del self._data.tools[tool_id]
            self.save()


# Global state manager instance
_state_manager: Optional[StateManager] = None


def get_state_manager() -> StateManager:
    """Get or create the global state manager instance."""
    global _state_manager
    if _state_manager is None:
        _state_manager = StateManager()
    return _state_manager


def check_tool_sync(check_cmd: str, timeout: float = 5.0) -> bool:
    """
    Synchronously check if a tool is installed using its check_cmd.
    
    Args:
        check_cmd: Shell command to verify installation
        timeout: Maximum time to wait for check (seconds)
    
    Returns:
        True if check passes (exit code 0), False otherwise
    """
    if not check_cmd or not check_cmd.strip():
        return False
    
    try:
        result = subprocess.run(
            ["bash", "-c", check_cmd],
            capture_output=True,
            timeout=timeout,
            env=None,  # Use current environment
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, OSError):
        return False


async def check_tool_async(check_cmd: str, timeout: float = 5.0) -> bool:
    """
    Asynchronously check if a tool is installed using its check_cmd.
    
    Args:
        check_cmd: Shell command to verify installation
        timeout: Maximum time to wait for check (seconds)
    
    Returns:
        True if check passes (exit code 0), False otherwise
    """
    if not check_cmd or not check_cmd.strip():
        return False
    
    try:
        proc = await asyncio.create_subprocess_exec(
            "bash", "-c", check_cmd,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )
        await asyncio.wait_for(proc.wait(), timeout=timeout)
        return proc.returncode == 0
    except (asyncio.TimeoutError, OSError):
        return False


async def check_tools_batch_async(
    tools: List["Tool"], 
    timeout: float = 5.0,
    max_concurrent: int = 10
) -> Dict[str, bool]:
    """
    Check multiple tools concurrently with rate limiting.
    
    Args:
        tools: List of tools to check
        timeout: Timeout per check
        max_concurrent: Maximum concurrent checks
    
    Returns:
        Dictionary mapping tool_id to check result
    """
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def check_with_limit(tool: "Tool") -> tuple:
        async with semaphore:
            result = await check_tool_async(tool.check_cmd, timeout)
            return (tool.id, result)
    
    tasks = [check_with_limit(tool) for tool in tools]
    results = await asyncio.gather(*tasks)
    
    return dict(results)


def determine_tool_status(
    tool_id: str,
    check_passed: bool,
    state_manager: Optional[StateManager] = None,
) -> str:
    """
    Determine the display status for a tool based on dual verification.
    
    Logic:
    - check_passed=True  && has_record(success)  → "installed"
    - check_passed=True  && no_record            → "installed" (external)
    - check_passed=False && has_record(success)  → "broken"
    - check_passed=False && no_record/failed     → "pending"
    
    Args:
        tool_id: Tool identifier
        check_passed: Result of real-time check_cmd
        state_manager: Optional state manager (uses global if not provided)
    
    Returns:
        Status string: "installed", "broken", or "pending"
    """
    if state_manager is None:
        state_manager = get_state_manager()
    
    has_success_record = state_manager.has_successful_record(tool_id)
    
    if check_passed:
        # Tool is actually available
        return "installed"
    else:
        if has_success_record:
            # Was installed but now broken/uninstalled
            return "broken"
        else:
            # Never installed or previous install failed
            return "pending"


async def verify_and_update_tools(
    tools: List["Tool"],
    state_manager: Optional[StateManager] = None,
) -> Dict[str, str]:
    """
    Verify all tools and determine their statuses.
    
    This is the main entry point for dual verification:
    1. Run check_cmd for all tools concurrently
    2. Compare with state file records
    3. Update state file with check results
    4. Return determined statuses
    
    Args:
        tools: List of tools to verify
        state_manager: Optional state manager
    
    Returns:
        Dictionary mapping tool_id to status string
    """
    if state_manager is None:
        state_manager = get_state_manager()
    
    # Load state file
    state_manager.load()
    
    # Run all checks concurrently
    check_results = await check_tools_batch_async(tools)
    
    # Determine status for each tool and update records
    statuses = {}
    for tool in tools:
        check_passed = check_results.get(tool.id, False)
        status = determine_tool_status(tool.id, check_passed, state_manager)
        statuses[tool.id] = status
        
        # Update check result in state file
        state_manager.update_check_result(tool.id, check_passed)
    
    return statuses


def verify_tools_fast(tools: List["Tool"]) -> Dict[str, str]:
    """
    Synchronous fast verification for startup.
    
    Uses synchronous checks for faster startup UI display.
    
    Args:
        tools: List of tools to verify
    
    Returns:
        Dictionary mapping tool_id to status string
    """
    state_manager = get_state_manager()
    state_manager.load()
    
    statuses = {}
    for tool in tools:
        check_passed = check_tool_sync(tool.check_cmd, timeout=2.0)
        status = determine_tool_status(tool.id, check_passed, state_manager)
        statuses[tool.id] = status
        
        # Update check result
        state_manager.update_check_result(tool.id, check_passed)
    
    return statuses

