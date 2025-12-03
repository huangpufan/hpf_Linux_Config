#!/usr/bin/env python3
"""
Demo mode - shows the TUI without actually executing scripts
"""
import sys
import os

# Redirect installer.py to use demo mode
os.environ['TUI_DEMO_MODE'] = '1'

# Import and run
sys.path.insert(0, os.path.dirname(__file__))
from installer import *

# Override execute_tool for demo
original_execute_tool = execute_tool

async def demo_execute_tool(tool: Tool, state: AppState):
    """Demo version that simulates installation"""
    tool.status = Status.RUNNING
    tool.start_time = datetime.now().timestamp()
    tool.add_log(f"[演示模式] 开始模拟安装: {tool.name}")
    state.active_tasks += 1
    
    # Simulate installation steps
    steps = [
        "检查系统环境...",
        "下载依赖包...",
        "解压文件...",
        "配置环境变量...",
        "安装完成！"
    ]
    
    for i, step in enumerate(steps):
        await asyncio.sleep(0.5)
        tool.add_log(f"[{i+1}/{len(steps)}] {step}")
    
    tool.status = Status.SUCCESS
    tool.end_time = datetime.now().timestamp()
    tool.add_log(f"✓ 安装成功，耗时 {tool.elapsed_time}")
    state.active_tasks -= 1

# Replace with demo version
execute_tool = demo_execute_tool

if __name__ == "__main__":
    print("启动演示模式...\n")
    try:
        exit_code = asyncio.run(main())
        sys.exit(exit_code)
    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)


