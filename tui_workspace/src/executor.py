"""
Task execution engine for running installation scripts
"""

import asyncio
import os
from datetime import datetime
from pathlib import Path
from typing import List

from .models import Tool, AppState, Status


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
        
        if not tool.script_path.exists():
            tool.status = Status.FAILED
            tool.add_log(f"[错误] 脚本不存在: {tool.script_path}")
            return
        
        # Ensure executable
        tool.script_path.chmod(0o755)
        
        # Determine working directory (script's parent directory)
        cwd = tool.script_path.parent
        
        # Execute script
        proc = await asyncio.create_subprocess_exec(
            "bash", str(tool.script_path),
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.STDOUT,
            cwd=str(cwd),
            env={**os.environ, "DEBIAN_FRONTEND": "noninteractive"}
        )
        
        # Stream logs in real-time
        while True:
            line = await proc.stdout.readline()
            if not line:
                break
            decoded = line.decode('utf-8', errors='replace').rstrip()
            if decoded:
                tool.add_log(decoded)
        
        await proc.wait()
        
        # Update status based on exit code
        if proc.returncode == 0:
            tool.status = Status.SUCCESS
            tool.add_log(f"[成功] 安装完成，耗时 {tool.elapsed_time}")
        else:
            tool.status = Status.FAILED
            tool.add_log(f"[失败] 退出码: {proc.returncode}")
            
    except Exception as e:
        tool.status = Status.FAILED
        tool.add_log(f"[异常] {str(e)}")
    
    finally:
        tool.end_time = datetime.now().timestamp()
        state.active_tasks -= 1


async def install_selected(state: AppState):
    """Install all selected tools concurrently"""
    selected = state.get_selected_tools()
    if not selected:
        return
    
    # Filter out already running/completed tools
    pending = [t for t in selected if t.status == Status.PENDING]
    
    # Execute all pending tools concurrently
    tasks = [execute_tool(tool, state) for tool in pending]
    await asyncio.gather(*tasks)


