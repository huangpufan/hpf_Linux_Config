"""
System checks and prerequisites

Performance optimized: instant file-based checks, async network checks in background
"""

import asyncio
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

from .models import AppState


@dataclass
class SystemInfo:
    """System environment information"""
    # OS info
    os_name: str = "Unknown"           # Ubuntu, Debian, CentOS, etc.
    os_version: str = ""               # 22.04, 12, etc.
    os_codename: str = ""              # jammy, bookworm, etc.
    kernel_version: str = ""           # 5.15.0-xxx
    
    # Environment flags
    is_wsl: bool = False
    wsl_version: int = 0               # 1 or 2
    
    # Status checks
    has_sudo: bool = False
    has_ssh_key: bool = False          # SSH key file exists
    has_ssh_github: bool = False       # SSH key configured for GitHub
    source_changed: bool = False       # APT source changed to mirror
    
    # Loading states for async checks
    _ssh_github_checking: bool = field(default=False, repr=False)
    
    @property
    def os_display(self) -> str:
        """Get display string for OS"""
        if self.is_wsl:
            wsl_tag = f"WSL{self.wsl_version}" if self.wsl_version else "WSL"
            return f"{self.os_name} {self.os_version} ({wsl_tag})"
        return f"{self.os_name} {self.os_version}"


def check_sudo_sync() -> bool:
    """Synchronous sudo check via cached credentials file (instant)"""
    import subprocess
    try:
        result = subprocess.run(
            ["sudo", "-n", "true"],
            capture_output=True,
            timeout=1
        )
        return result.returncode == 0
    except Exception:
        return False


def check_ssh_key_exists_sync() -> bool:
    """Synchronous SSH key check (instant file check)"""
    ssh_dir = Path.home() / ".ssh"
    key_files = ["id_rsa.pub", "id_ed25519.pub", "id_ecdsa.pub"]
    return any((ssh_dir / key).exists() for key in key_files)


def check_wsl_sync() -> tuple[bool, int]:
    """Synchronous WSL check (instant file read)"""
    try:
        with open("/proc/version", "r") as f:
            content = f.read().lower()
            if "microsoft" not in content:
                return False, 0
            if "wsl2" in content or "-microsoft-standard" in content:
                return True, 2
            return True, 1
    except Exception:
        return False, 0


def get_os_info_sync() -> tuple[str, str, str]:
    """Synchronous OS info (instant file read)"""
    os_name = "Unknown"
    os_version = ""
    os_codename = ""
    
    try:
        with open("/etc/os-release", "r") as f:
            for line in f:
                line = line.strip()
                if line.startswith("NAME="):
                    os_name = line.split("=", 1)[1].strip('"')
                elif line.startswith("VERSION_ID="):
                    os_version = line.split("=", 1)[1].strip('"')
                elif line.startswith("VERSION_CODENAME="):
                    os_codename = line.split("=", 1)[1].strip('"')
    except Exception:
        pass
    
    return os_name, os_version, os_codename


def get_kernel_version_sync() -> str:
    """Synchronous kernel version (instant file read)"""
    try:
        with open("/proc/version", "r") as f:
            content = f.read()
            parts = content.split()
            if len(parts) >= 3:
                return parts[2]
    except Exception:
        pass
    return ""


def check_source_changed_sync() -> bool:
    """Synchronous APT source check (instant file read)"""
    sources_file = Path("/etc/apt/sources.list")
    
    mirrors = [
        "mirrors.aliyun.com",
        "mirrors.tuna.tsinghua.edu.cn",
        "mirrors.ustc.edu.cn",
        "mirrors.163.com",
        "mirrors.huaweicloud.com",
        "mirrors.cloud.tencent.com",
    ]
    
    try:
        if sources_file.exists():
            content = sources_file.read_text()
            return any(mirror in content for mirror in mirrors)
    except Exception:
        pass
    
    return False


async def check_ssh_github_async() -> bool:
    """Async SSH GitHub check with short timeout (runs in background)"""
    try:
        proc = await asyncio.create_subprocess_exec(
            "ssh", "-T", "-o", "StrictHostKeyChecking=no", 
            "-o", "ConnectTimeout=2", "-o", "BatchMode=yes",
            "git@github.com",
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL
        )
        await asyncio.wait_for(proc.wait(), timeout=3)
        return proc.returncode in [0, 1]
    except asyncio.TimeoutError:
        return False
    except Exception:
        return False


# Keep async versions for backward compatibility
async def check_sudo() -> bool:
    """Check if sudo is available without password"""
    return check_sudo_sync()


async def check_ssh_key_exists() -> bool:
    """Check if SSH key file exists locally"""
    return check_ssh_key_exists_sync()


async def check_ssh_github() -> bool:
    """Check if SSH key is configured for GitHub"""
    return await check_ssh_github_async()


async def check_wsl() -> tuple[bool, int]:
    """Check if running under WSL and return WSL version"""
    return check_wsl_sync()


async def get_os_info() -> tuple[str, str, str]:
    """Get OS name, version, and codename from /etc/os-release"""
    return get_os_info_sync()


async def get_kernel_version() -> str:
    """Get kernel version"""
    return get_kernel_version_sync()


async def check_source_changed() -> bool:
    """Check if APT source has been changed to a mirror"""
    return check_source_changed_sync()


def collect_system_info_fast() -> SystemInfo:
    """
    Collect system information INSTANTLY using synchronous file reads.
    SSH GitHub check is skipped (deferred to background).
    """
    info = SystemInfo()
    
    # All these are instant file reads (< 1ms total)
    info.os_name, info.os_version, info.os_codename = get_os_info_sync()
    info.kernel_version = get_kernel_version_sync()
    info.is_wsl, info.wsl_version = check_wsl_sync()
    info.has_sudo = check_sudo_sync()
    info.has_ssh_key = check_ssh_key_exists_sync()
    info.source_changed = check_source_changed_sync()
    
    # SSH GitHub: defer to background, initially False
    info.has_ssh_github = False
    info._ssh_github_checking = True
    
    return info


async def collect_system_info() -> SystemInfo:
    """Collect all system information (legacy async version)"""
    info = SystemInfo()
    
    # Run all checks concurrently
    (
        (info.os_name, info.os_version, info.os_codename),
        info.kernel_version,
        (info.is_wsl, info.wsl_version),
        info.has_sudo,
        info.has_ssh_key,
        info.has_ssh_github,
        info.source_changed,
    ) = await asyncio.gather(
        get_os_info(),
        get_kernel_version(),
        check_wsl(),
        check_sudo(),
        check_ssh_key_exists(),
        check_ssh_github(),
        check_source_changed(),
    )
    
    return info


def check_system_fast(state: AppState) -> None:
    """
    INSTANT system check - no blocking, no async wait.
    Call this to get UI up immediately.
    """
    state.system_info = collect_system_info_fast()
    
    # Keep backward compatibility
    state.has_sudo = state.system_info.has_sudo
    state.has_ssh = state.system_info.has_ssh_github
    state.is_wsl = state.system_info.is_wsl


async def check_ssh_github_background(state: AppState) -> None:
    """
    Background task to check SSH GitHub connectivity.
    Updates state when complete.
    """
    if state.system_info is None:
        return
    
    result = await check_ssh_github_async()
    state.system_info.has_ssh_github = result
    state.system_info._ssh_github_checking = False
    state.has_ssh = result


async def check_system(state: AppState):
    """Run all system checks and update state (legacy)"""
    state.system_info = await collect_system_info()
    
    # Keep backward compatibility
    state.has_sudo = state.system_info.has_sudo
    state.has_ssh = state.system_info.has_ssh_github
    state.is_wsl = state.system_info.is_wsl


