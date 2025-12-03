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


class Application:
    """Main TUI application"""
    
    def __init__(self, config: Config):
        self.config = config
        self.console = Console()
        self.state = None
    
    async def initialize(self):
        """Initialize application state"""
        # Load configuration
        categories = self.config.load()
        self.state = AppState(categories)
        
        # Check system prerequisites
        with self.console.status("[cyan]正在检查系统环境...[/]"):
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
                refresh_per_second=5,
                screen=True
            ) as live:
                
                # Main event loop
                while self.state.running:
                    try:
                        # Get key with timeout using wait_for for proper cancellation
                        try:
                            key = await asyncio.wait_for(kbd.get_key(), timeout=0.2)
                            await handle_input(self.state, key)
                        except asyncio.TimeoutError:
                            pass  # No input within timeout, continue loop
                        
                        # Update UI
                        live.update(render_ui(self.state))
                        
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
            self.console.print(f"  [green]✓ 成功: {success_count}[/]")
            if failed_count > 0:
                self.console.print(f"  [red]✗ 失败: {failed_count}[/]")
