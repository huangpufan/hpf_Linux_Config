"""
Task execution engine for running installation scripts
"""

import asyncio
import os
from datetime import datetime
from pathlib import Path
from typing import List

from .constants import SUDO_REFRESH_TIMEOUT, CHECK_CMD_TIMEOUT
from .models import Tool, AppState, Status
from .state import get_state_manager, check_tool_async


async def refresh_sudo_credentials() -> bool:
    """
    Attempt to refresh sudo credentials before executing a script.
    
    Returns:
        True if sudo credentials are valid, False otherwise
    """
    try:
        refresh_proc = await asyncio.create_subprocess_exec(
            "sudo", "-v",
            stdin=asyncio.subprocess.DEVNULL,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )
        await asyncio.wait_for(refresh_proc.wait(), timeout=SUDO_REFRESH_TIMEOUT)
        return refresh_proc.returncode == 0
    except (asyncio.TimeoutError, OSError):
        return False


async def execute_tool(tool: Tool, state: AppState):
    """Execute a tool installation script asynchronously"""
    tool.status = Status.RUNNING
    tool.start_time = datetime.now().timestamp()
    tool.add_log(f"开始执行: {tool.script_path}")
    state.active_tasks += 1
    
    try:
        # Check prerequisites
        if tool.requires_ssh and not state.has_ssh:
            tool.status = Status.SKIPPED
            tool.add_log("[警告] 需要SSH密钥配置，已跳过")
            return
        
        # Refresh sudo credentials if needed (prevent race condition)
        if tool.requires_sudo:
            tool.add_log("[检查] 刷新 sudo 凭证...")
            if not await refresh_sudo_credentials():
                tool.status = Status.FAILED
                tool.add_log("[错误] sudo 凭证已过期，请重新运行程序")
                return
        
        if not tool.script_path.exists():
            tool.status = Status.FAILED
            tool.add_log(f"[错误] 脚本不存在: {tool.script_path}")
            return
        
        # Ensure executable
        tool.script_path.chmod(0o755)
        
        # Determine working directory (script's parent directory)
        cwd = tool.script_path.parent
        
        # Execute script
        # stdin=DEVNULL prevents scripts from blocking on user input
        # (e.g., SSH passphrase prompts, git credential prompts)
        proc = await asyncio.create_subprocess_exec(
            "bash", str(tool.script_path),
            stdin=asyncio.subprocess.DEVNULL,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.STDOUT,
            cwd=str(cwd),
            env={**os.environ, "DEBIAN_FRONTEND": "noninteractive"}
        )
        
        # Stream logs in real-time with timeout control
        timed_out = False
        try:
            async def read_output():
                while True:
                    line = await proc.stdout.readline()
                    if not line:
                        break
                    decoded = line.decode('utf-8', errors='replace').rstrip()
                    if decoded:
                        tool.add_log(decoded)
                await proc.wait()
            
            await asyncio.wait_for(read_output(), timeout=tool.timeout)
        except asyncio.TimeoutError:
            timed_out = True
            tool.add_log(f"[超时] 执行超过 {tool.timeout} 秒，正在终止进程...")
            proc.kill()
            await proc.wait()
        
        # Update status based on exit code or timeout
        if timed_out:
            tool.status = Status.FAILED
            tool.add_log(f"[失败] 脚本执行超时 ({tool.timeout}秒)")
            
            # Record timeout as failed installation
            state_mgr = get_state_manager()
            state_mgr.record_install(tool.id, success=False)
        elif proc.returncode == 0:
            tool.status = Status.SUCCESS
            tool.add_log(f"[成功] 安装完成，耗时 {tool.elapsed_time}")
            
            # Verify installation with check_cmd
            if tool.check_cmd:
                tool.add_log("[验证] 检测安装结果...")
                check_passed = await check_tool_async(tool.check_cmd, timeout=CHECK_CMD_TIMEOUT)
                if check_passed:
                    tool.add_log("[验证] ✓ 检测通过")
                else:
                    tool.add_log("[验证] ⚠ 检测未通过，可能需要重启终端")
            
            # Record successful installation to state file
            state_mgr = get_state_manager()
            state_mgr.record_install(tool.id, success=True)
        else:
            tool.status = Status.FAILED
            tool.add_log(f"[失败] 退出码: {proc.returncode}")
            
            # Record failed installation to state file
            state_mgr = get_state_manager()
            state_mgr.record_install(tool.id, success=False)
            
    except Exception as e:
        tool.status = Status.FAILED
        tool.add_log(f"[异常] {str(e)}")
        
        # Record exception as failed installation
        state_mgr = get_state_manager()
        state_mgr.record_install(tool.id, success=False)
    
    finally:
        tool.end_time = datetime.now().timestamp()
        state.active_tasks -= 1


async def install_selected(state: AppState):
    """Install all selected tools concurrently"""
    selected = state.get_selected_tools()
    if not selected:
        return
    
    # Filter out already running/completed/installed tools
    # Allow re-installation of BROKEN and FAILED tools
    pending = [t for t in selected if t.is_installable]
    
    # Execute all pending tools concurrently
    tasks = [execute_tool(tool, state) for tool in pending]
    await asyncio.gather(*tasks)


