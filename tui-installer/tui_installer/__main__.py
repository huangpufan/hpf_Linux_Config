#!/usr/bin/env python3
"""
HPF Linux Config - Interactive TUI Installer
Entry point for `python -m tui_installer`
"""

import asyncio
import os
import sys

from .config import Config
from .app import Application
from .system import check_sudo_sync


def check_sudo_available() -> bool:
    """Check if we have sudo privileges (root or cached sudo credentials)"""
    # Running as root
    if os.geteuid() == 0:
        return True
    # Sudo credentials cached (can run sudo without password)
    return check_sudo_sync()


async def main() -> int:
    """Main application entry point"""
    # Check sudo privileges before starting
    if not check_sudo_available():
        print("\033[1;31m错误: 需要 sudo 权限才能运行安装程序\033[0m", file=sys.stderr)
        print("", file=sys.stderr)
        print("请先缓存 sudo 凭证后运行:", file=sys.stderr)
        print("  \033[1;32msudo -v && python -m tui_installer\033[0m", file=sys.stderr)
        return 1
    
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

