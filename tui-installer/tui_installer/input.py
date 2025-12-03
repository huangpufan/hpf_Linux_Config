"""
Keyboard input handling
"""

import asyncio
import sys
import termios
import tty
import select

from .models import AppState
from .executor import execute_tool, install_selected


class KeyboardInput:
    """Non-blocking keyboard input handler using standard library"""
    
    def __enter__(self):
        self.fd = sys.stdin.fileno()
        self.old_settings = termios.tcgetattr(self.fd)
        tty.setcbreak(self.fd)
        return self
    
    def __exit__(self, *args):
        termios.tcsetattr(self.fd, termios.TCSADRAIN, self.old_settings)
    
    async def get_key(self) -> str:
        """Get next keypress asynchronously"""
        loop = asyncio.get_event_loop()
        
        def read():
            # Use select to check if data is available (non-blocking)
            if select.select([sys.stdin], [], [], 0)[0]:
                ch = sys.stdin.read(1)
                # Handle ANSI escape sequences for arrow keys
                if ch == '\x1b':
                    # Check if more data available (escape sequence)
                    if select.select([sys.stdin], [], [], 0.1)[0]:
                        seq = sys.stdin.read(2)
                        if seq == '[A':
                            return 'UP'
                        elif seq == '[B':
                            return 'DOWN'
                        elif seq == '[C':
                            return 'RIGHT'
                        elif seq == '[D':
                            return 'LEFT'
                return ch
            return None
        
        try:
            while True:
                key = await loop.run_in_executor(None, read)
                if key is not None:
                    return key
                await asyncio.sleep(0.05)  # Small delay to prevent CPU spin
        except asyncio.CancelledError:
            # Task was cancelled (timeout), exit cleanly
            raise


async def handle_input(state: AppState, key: str):
    """Handle keyboard input with Vim-style keybindings"""
    
    # Quit
    if key in ('q', 'Q'):
        state.running = False
    
    # Navigation - vertical (j/k based on focus_panel)
    elif key in ('j', 'DOWN'):
        if state.view_mode == "list":
            if state.focus_panel == "sidebar":
                state.move_category(1)
            else:
                state.move_tool(1)
    
    elif key in ('k', 'UP'):
        if state.view_mode == "list":
            if state.focus_panel == "sidebar":
                state.move_category(-1)
            else:
                state.move_tool(-1)
    
    # Navigation - horizontal (h/l to switch focus panel)
    elif key in ('h', 'LEFT'):
        if state.view_mode == "list":
            state.focus_panel = "sidebar"
    
    elif key in ('l', 'RIGHT'):
        if state.view_mode == "list":
            state.focus_panel = "body"
    
    # Selection
    elif key == ' ':  # Space
        state.toggle_selection()
    
    # View toggle
    elif key in ('\r', '\n'):  # Enter
        if state.view_mode == "list":
            state.view_mode = "logs"
        else:
            state.view_mode = "list"
    
    # Install current tool
    elif key in ('i', 'I'):
        if tool := state.current_tool:
            from .models import Status
            if tool.status == Status.PENDING:
                tool.selected = True
                asyncio.create_task(execute_tool(tool, state))
    
    # Install all selected tools
    elif key in ('a', 'A'):
        if state.get_selected_tools():
            asyncio.create_task(install_selected(state))
    
    # Toggle logs view (alternative keybinding)
    elif key == 'L':
        state.view_mode = "logs" if state.view_mode == "list" else "list"

