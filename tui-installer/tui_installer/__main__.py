#!/usr/bin/env python3
"""
HPF Linux Config - Interactive TUI Installer
Entry point for `python -m tui_installer`
"""

import asyncio
import sys

from .config import Config
from .app import Application


async def main() -> int:
    """Main application entry point"""
    try:
        config = Config.default()
        app = Application(config)
        await app.run()
        return 0

    except FileNotFoundError as e:
        print(f"错误: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"致命错误: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


def run() -> None:
    """Entry point for console script"""
    try:
        exit_code = asyncio.run(main())
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n用户中断")
        sys.exit(130)


if __name__ == "__main__":
    run()

