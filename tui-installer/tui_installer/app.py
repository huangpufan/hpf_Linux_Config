"""
Main application logic and event loop
"""

import asyncio
from typing import List, Optional

from rich.console import Console
from rich.live import Live

from .config import Config
from .constants import UI_REFRESH_RATE, INPUT_POLL_INTERVAL
from .models import AppState, Status
from .system import check_system_fast, check_ssh_github_background
from .state import StateManager, verify_tools_fast, verify_and_update_tools
from .input import KeyboardInput, handle_input
from .ui import render_ui
from .theme import Theme


class Application:
    """Main TUI application"""
    
    def __init__(self, config: Config, state_manager: Optional[StateManager] = None):
        """
        Initialize the application.
        
        Args:
            config: Application configuration
            state_manager: Optional StateManager instance for dependency injection.
                          If not provided, uses the global singleton.
        """
        self.config = config
        self.state_manager = state_manager
        # Force truecolor (24-bit) to ensure consistent colors across terminals
        self.console = Console(force_terminal=True, color_system="truecolor")
        self.state: Optional[AppState] = None
        self._background_tasks: List[asyncio.Task] = []
    
    def initialize_fast(self):
        """
        INSTANT initialization - no blocking, no async wait.
        UI will be available immediately.
        """
        # Load configuration (fast JSON parse)
        categories = self.config.load()
        self.state = AppState(categories, state_manager=self.state_manager)
        
        # Instant system check (file reads only, ~1ms)
        check_system_fast(self.state)
        
        # Verify tool installation status (dual verification)
        # Uses local state file + real-time check_cmd detection
        all_tools = self.state.all_tools
        statuses = verify_tools_fast(all_tools, state_manager=self.state_manager)
        for tool in all_tools:
            if tool.id in statuses:
                tool.apply_verified_status(statuses[tool.id])
    
    async def run(self):
        """Main application loop"""
        if not self.state:
            self.initialize_fast()
        
        # Start interactive UI
        with KeyboardInput() as kbd:
            with Live(
                render_ui(self.state),
                console=self.console,
                refresh_per_second=UI_REFRESH_RATE,
                screen=True
            ) as live:
                
                # Start SSH GitHub check in background (doesn't block UI)
                ssh_task = asyncio.create_task(check_ssh_github_background(self.state))
                self._background_tasks.append(ssh_task)
                
                # Main event loop - optimized for responsiveness
                while self.state.running:
                    try:
                        # Get key with short timeout for responsive input
                        try:
                            key = await asyncio.wait_for(kbd.get_key(), timeout=INPUT_POLL_INTERVAL)
                            await handle_input(self.state, key)
                            # Immediate UI update after input - key response
                            live.update(render_ui(self.state))
                        except asyncio.TimeoutError:
                            pass  # No input within timeout, Live handles refresh
                        
                    except KeyboardInterrupt:
                        self.state.running = False
                
                # Cancel background tasks on exit
                for task in self._background_tasks:
                    if not task.done():
                        task.cancel()
        
        # Show summary
        self.show_summary()
    
    def show_summary(self):
        """Display installation summary"""
        all_tools = self.state.all_tools
        success_count = sum(1 for t in all_tools if t.status == Status.SUCCESS)
        installed_count = sum(1 for t in all_tools if t.status == Status.INSTALLED)
        failed_count = sum(1 for t in all_tools if t.status == Status.FAILED)
        
        if success_count > 0 or failed_count > 0:
            self.console.print(f"\n[bold]安装总结:[/]")
            if success_count > 0:
                self.console.print(f"  [{Theme.GREEN}]✓ 本次成功: {success_count}[/]")
            if installed_count > 0:
                self.console.print(f"  [{Theme.CYAN}]✓ 已安装: {installed_count}[/]")
            if failed_count > 0:
                self.console.print(f"  [{Theme.RED}]✗ 失败: {failed_count}[/]")
