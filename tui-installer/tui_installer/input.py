"""
Keyboard input handling
"""

import asyncio
import sys
import termios
import tty
import select
from typing import Optional

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
    
    def read_key_sync(self) -> Optional[str]:
        """Synchronously read a key if available (non-blocking)
        
        Optimized: reduced select timeouts for faster key response
        """
        # Use select with minimal timeout - just check if data is available
        # 1ms is enough to detect available data without blocking
        if select.select([sys.stdin], [], [], 0.001)[0]:
            ch = sys.stdin.read(1)
            # Handle ANSI escape sequences for arrow keys
            if ch == '\x1b':
                # Check if more data available (escape sequence)
                # Use very short timeout - escape sequences arrive together
                if select.select([sys.stdin], [], [], 0.005)[0]:
                    seq = sys.stdin.read(2)
                    if seq == '[A':
                        return 'UP'
                    elif seq == '[B':
                        return 'DOWN'
                    elif seq == '[C':
                        return 'RIGHT'
                    elif seq == '[D':
                        return 'LEFT'
                # Single ESC key pressed (no sequence following)
                return ch
            return ch
        return None
    
    async def get_key(self) -> str:
        """Get next keypress asynchronously with minimal latency
        
        Optimized: shorter sleep intervals for faster response
        """
        loop = asyncio.get_running_loop()
        
        try:
            while True:
                # Run blocking read in executor with built-in select timeout
                key = await loop.run_in_executor(None, self.read_key_sync)
                if key is not None:
                    return key
                # Minimal yield - 1ms is enough to prevent busy-wait
                await asyncio.sleep(0.001)
        except asyncio.CancelledError:
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
    
    # Enter key - context-sensitive action
    elif key in ('\r', '\n'):  # Enter
        if state.view_mode == "logs":
            # In logs view: return to list
            state.view_mode = "list"
        elif state.focus_panel == "sidebar":
            # In sidebar: enter the category (switch focus to body)
            state.focus_panel = "body"
        else:
            # In body (tool list): install current tool (same as 'i')
            if tool := state.current_tool:
                if tool.is_installable:
                    tool.selected = True
                    task = asyncio.create_task(execute_tool(tool, state))
                    state.running_tasks.append(task)
    
    # Install current tool
    elif key in ('i', 'I'):
        if tool := state.current_tool:
            # Allow installation for PENDING, BROKEN, and FAILED tools
            if tool.is_installable:
                tool.selected = True
                task = asyncio.create_task(execute_tool(tool, state))
                state.running_tasks.append(task)
    
    # Install all selected tools
    elif key in ('a', 'A'):
        if state.get_selected_tools():
            task = asyncio.create_task(install_selected(state))
            state.running_tasks.append(task)
    
    # Toggle logs view (alternative keybinding)
    elif key == 'L':
        state.view_mode = "logs" if state.view_mode == "list" else "list"

