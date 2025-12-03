"""
Main application logic and event loop
"""

import asyncio
from rich.console import Console
from rich.live import Live

from .config import Config
from .models import AppState, Status
from .system import check_system
from .input import KeyboardInput, handle_input
from .ui import render_ui
from .theme import Theme


class Application:
    """Main TUI application"""
    
    def __init__(self, config: Config):
        self.config = config
        # Force truecolor (24-bit) to ensure consistent colors across terminals
        self.console = Console(force_terminal=True, color_system="truecolor")
        self.state = None
    
    async def initialize(self):
        """Initialize application state"""
        # Load configuration
        categories = self.config.load()
        self.state = AppState(categories)
        
        # Check system prerequisites
        with self.console.status(f"[{Theme.CYAN}]正在检查系统环境...[/]"):
            await check_system(self.state)
    
    async def run(self):
        """Main application loop"""
        if not self.state:
            await self.initialize()
        
        # Start interactive UI
        with KeyboardInput() as kbd:
            with Live(
                render_ui(self.state),
                console=self.console,
                refresh_per_second=30,  # Higher refresh rate for smoother UI
                screen=True
            ) as live:
                
                # Main event loop
                while self.state.running:
                    try:
                        # Get key with short timeout for responsive input
                        try:
                            key = await asyncio.wait_for(kbd.get_key(), timeout=0.03)
                            await handle_input(self.state, key)
                            # Immediate UI update after input
                            live.update(render_ui(self.state))
                        except asyncio.TimeoutError:
                            pass  # No input within timeout, Live handles refresh
                        
                    except KeyboardInterrupt:
                        self.state.running = False
        
        # Show summary
        self.show_summary()
    
    def show_summary(self):
        """Display installation summary"""
        all_tools = self.state.all_tools
        success_count = sum(1 for t in all_tools if t.status == Status.SUCCESS)
        failed_count = sum(1 for t in all_tools if t.status == Status.FAILED)
        
        if success_count > 0 or failed_count > 0:
            self.console.print(f"\n[bold]安装总结:[/]")
            self.console.print(f"  [{Theme.GREEN}]✓ 成功: {success_count}[/]")
            if failed_count > 0:
                self.console.print(f"  [{Theme.RED}]✗ 失败: {failed_count}[/]")
