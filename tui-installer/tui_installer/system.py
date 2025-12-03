"""
System checks and prerequisites
"""

import asyncio
from dataclasses import dataclass
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
    
    @property
    def os_display(self) -> str:
        """Get display string for OS"""
        if self.is_wsl:
            wsl_tag = f"WSL{self.wsl_version}" if self.wsl_version else "WSL"
            return f"{self.os_name} {self.os_version} ({wsl_tag})"
        return f"{self.os_name} {self.os_version}"


async def check_sudo() -> bool:
    """Check if sudo is available without password"""
    proc = await asyncio.create_subprocess_exec(
        "sudo", "-n", "true",
        stdout=asyncio.subprocess.DEVNULL,
        stderr=asyncio.subprocess.DEVNULL
    )
    await proc.wait()
    return proc.returncode == 0


async def check_ssh_key_exists() -> bool:
    """Check if SSH key file exists locally"""
    ssh_dir = Path.home() / ".ssh"
    key_files = ["id_rsa.pub", "id_ed25519.pub", "id_ecdsa.pub"]
    return any((ssh_dir / key).exists() for key in key_files)


async def check_ssh_github() -> bool:
    """Check if SSH key is configured for GitHub"""
    try:
        proc = await asyncio.create_subprocess_exec(
            "ssh", "-T", "-o", "StrictHostKeyChecking=no", 
            "-o", "ConnectTimeout=5", "git@github.com",
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL
        )
        await asyncio.wait_for(proc.wait(), timeout=10)
        # returncode 1 means "authenticated but no shell access"
        return proc.returncode in [0, 1]
    except asyncio.TimeoutError:
        return False
    except Exception:
        return False


async def check_wsl() -> tuple[bool, int]:
    """Check if running under WSL and return WSL version"""
    try:
        with open("/proc/version", "r") as f:
            content = f.read().lower()
            if "microsoft" not in content:
                return False, 0
            
            # Detect WSL version
            # WSL2 typically has newer kernel versions (5.x+)
            if "wsl2" in content or "-microsoft-standard" in content:
                return True, 2
            return True, 1
    except Exception:
        return False, 0


async def get_os_info() -> tuple[str, str, str]:
    """Get OS name, version, and codename from /etc/os-release"""
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


async def get_kernel_version() -> str:
    """Get kernel version"""
    try:
        with open("/proc/version", "r") as f:
            content = f.read()
            # Extract kernel version (e.g., "5.15.167.4-microsoft-standard-WSL2")
            parts = content.split()
            if len(parts) >= 3:
                return parts[2]
    except Exception:
        pass
    return ""


async def check_source_changed() -> bool:
    """Check if APT source has been changed to a mirror"""
    sources_file = Path("/etc/apt/sources.list")
    
    # Common China mirrors to check
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


async def collect_system_info() -> SystemInfo:
    """Collect all system information"""
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


async def check_system(state: AppState):
    """Run all system checks and update state"""
    state.system_info = await collect_system_info()
    
    # Keep backward compatibility
    state.has_sudo = state.system_info.has_sudo
    state.has_ssh = state.system_info.has_ssh_github
    state.is_wsl = state.system_info.is_wsl


