#!/usr/bin/env python3
"""
HPF Linux Config - Interactive TUI Installer
Modern terminal UI installer with Vim-style keybindings and async task execution

Entry point for the modularized application
"""

import asyncio
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent))

from src.config import Config
from src.app import Application


async def main():
    """Main application entry point"""
    try:
        # Load configuration
        config = Config.default()
        
        # Create and run application
        app = Application(config)
        await app.run()
        
        return 0
        
    except FileNotFoundError as e:
        print(f"错误: {e}")
        return 1
    except Exception as e:
        print(f"致命错误: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    try:
        exit_code = asyncio.run(main())
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n用户中断")
        sys.exit(130)


