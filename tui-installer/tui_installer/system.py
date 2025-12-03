"""
System checks and prerequisites
"""

import asyncio
from .models import AppState


async def check_sudo() -> bool:
    """Check if sudo is available without password"""
    proc = await asyncio.create_subprocess_exec(
        "sudo", "-n", "true",
        stdout=asyncio.subprocess.DEVNULL,
        stderr=asyncio.subprocess.DEVNULL
    )
    await proc.wait()
    return proc.returncode == 0


async def check_ssh() -> bool:
    """Check if SSH key is configured for GitHub"""
    proc = await asyncio.create_subprocess_exec(
        "ssh", "-T", "git@github.com",
        stdout=asyncio.subprocess.DEVNULL,
        stderr=asyncio.subprocess.DEVNULL
    )
    await proc.wait()
    # returncode 1 means "authenticated but no shell access"
    return proc.returncode in [0, 1]


async def check_wsl() -> bool:
    """Check if running under WSL"""
    try:
        with open("/proc/version", "r") as f:
            return "microsoft" in f.read().lower()
    except:
        return False


async def check_system(state: AppState):
    """Run all system checks and update state"""
    state.has_sudo = await check_sudo()
    state.has_ssh = await check_ssh()
    state.is_wsl = await check_wsl()


