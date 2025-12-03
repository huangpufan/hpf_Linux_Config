"""
UI rendering components using Rich library
"""

from datetime import datetime
from rich.console import Console
from rich.layout import Layout
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich import box

from .models import AppState, STATUS_ICONS, Status


def make_header(state: AppState) -> Panel:
    """Render application header with status"""
    grid = Table.grid(expand=True)
    grid.add_column(justify="left", ratio=1)
    grid.add_column(justify="center")
    grid.add_column(justify="right")
    
    # Title
    title = Text("HPF LINUX CONFIG", style="bold cyan")
    title.append(" Installer v2.0", style="dim")
    
    # Status indicators
    status_parts = []
    if state.active_tasks > 0:
        status_parts.append(f"🔄 {state.active_tasks} 任务运行中")
    if not state.has_sudo:
        status_parts.append("⚠️ 无sudo权限")
    status_text = " | ".join(status_parts) if status_parts else "就绪"
    
    # Current time
    time_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    grid.add_row(title, Text(status_text, style="yellow"), Text(time_str))
    
    return Panel(grid, style="white on #1e1e2e", box=box.ROUNDED)


def make_sidebar(state: AppState) -> Panel:
    """Render category sidebar navigation"""
    table = Table(show_header=False, box=None, expand=True)
    table.add_column("Item")
    
    is_focused = state.focus_panel == "sidebar"
    
    for idx, cat in enumerate(state.categories):
        is_selected = (idx == state.current_category_idx)
        
        # Count completed tools
        total = len(cat.tools)
        done = sum(1 for t in cat.tools if t.status == Status.SUCCESS)
        
        label = f"{cat.icon}  {cat.name}"
        if total > 0:
            label += f" [{done}/{total}]"
        
        if is_selected:
            text = Text(f"▶ {label}", style="bold cyan on #2b2b3b")
        else:
            text = Text(f"  {label}", style="dim white")
        
        table.add_row(text)
    
    # 根据焦点状态设置边框颜色
    border_style = "bold cyan" if is_focused else "dim blue"
    title = "[b cyan]分类[/]" if is_focused else "[b]分类[/]"
    
    return Panel(
        table,
        title=title,
        border_style=border_style,
        style="on #1e1e2e",
        box=box.ROUNDED
    )


def make_tool_list(state: AppState) -> Panel:
    """Render tool list for current category"""
    cat = state.current_category
    
    is_focused = state.focus_panel == "body"
    
    table = Table(box=box.SIMPLE, expand=True, show_header=True, show_lines=False)
    table.add_column("", width=2, justify="center")  # 选择列，去掉表头
    table.add_column("状态", width=6)
    table.add_column("工具", width=18)
    table.add_column("描述", style="dim", ratio=1)
    table.add_column("耗时", width=6, justify="right")
    
    for idx, tool in enumerate(cat.tools):
        is_row_focused = (idx == state.current_tool_idx)
        
        # Checkbox
        check = "[green]✓[/]" if tool.selected else "·"
        
        # Status
        icon, color, text = STATUS_ICONS[tool.status]
        status_text = Text(text, style=color)
        
        # Highlight focused row
        row_style = "on #2b2b3b" if is_row_focused else ""
        name = f"[bold]{tool.name}[/]" if is_row_focused else tool.name
        
        table.add_row(
            check,
            status_text,
            name,
            tool.description,
            tool.elapsed_time,
            style=row_style
        )
    
    # 根据焦点状态设置边框颜色
    border_style = "bold cyan" if is_focused else "dim white"
    title = f"[b cyan]{cat.icon} {cat.name}[/]" if is_focused else f"[b]{cat.icon} {cat.name}[/]"
    
    return Panel(
        table,
        title=title,
        subtitle="[dim]j/k:移动 Space:选择 i:安装 a:批量安装 Enter:查看日志[/]",
        border_style=border_style,
        style="on #1e1e2e",
        box=box.ROUNDED
    )


def make_logs(state: AppState) -> Panel:
    """Render logs for current tool"""
    tool = state.current_tool
    if not tool:
        return Panel(
            Text("没有选中工具", style="dim"),
            title="[b]日志[/]",
            border_style="yellow",
            style="on #1e1e2e",
            box=box.ROUNDED
        )
    
    # Get last 40 lines for better visibility
    log_lines = list(tool.logs)[-40:]
    
    if log_lines:
        log_text = Text("\n".join(log_lines), overflow="fold")
    else:
        log_text = Text("暂无日志 - 按 [i] 安装后查看", style="dim")
    
    status_icon, status_color, status_text = STATUS_ICONS[tool.status]
    title = f"[b]{tool.name}[/] - [{status_color}]{status_text}[/]"
    
    # Show elapsed time in subtitle
    subtitle = "[dim]Enter:返回列表"
    if tool.elapsed_time:
        subtitle += f" | 耗时: {tool.elapsed_time}"
    subtitle += "[/]"
    
    return Panel(
        log_text,
        title=title,
        subtitle=subtitle,
        border_style="yellow",
        style="on #1e1e2e",
        box=box.ROUNDED
    )


def make_preview(state: AppState) -> Panel:
    """Render script preview panel for current tool"""
    tool = state.current_tool
    if not tool:
        return Panel(
            Text("选择一个工具查看详情", style="dim"),
            title="[b]脚本预览[/]",
            border_style="dim magenta",
            style="on #1e1e2e",
            box=box.ROUNDED
        )
    
    from rich.syntax import Syntax
    
    # Build info section
    info_parts = []
    info_parts.append(f"[bold cyan]{tool.name}[/]")
    info_parts.append(f"[dim]{tool.description}[/]")
    info_parts.append("")
    
    # Requirements
    reqs = []
    if tool.requires_sudo:
        reqs.append("[yellow]⚡ 需要 sudo 权限[/]")
    if tool.requires_ssh:
        reqs.append("[blue]🔑 需要 SSH 密钥[/]")
    if reqs:
        info_parts.extend(reqs)
        info_parts.append("")
    
    info_parts.append(f"[dim]脚本路径: {tool.script_rel}[/]")
    info_parts.append("[dim]─" * 30 + "[/]")
    
    info_text = "\n".join(info_parts)
    
    # Get script content
    script_content = tool.get_script_content(max_lines=25)
    
    try:
        # Use Syntax highlighting for bash scripts
        syntax = Syntax(
            script_content, 
            "bash", 
            theme="monokai",
            line_numbers=True,
            word_wrap=True,
            background_color="#1e1e2e"
        )
        from rich.console import Group
        content = Group(Text.from_markup(info_text), syntax)
    except Exception:
        # Fallback to plain text
        content = Text(f"{info_text}\n\n{script_content}", overflow="fold")
    
    return Panel(
        content,
        title="[b magenta]📜 脚本预览[/]",
        border_style="magenta",
        style="on #1e1e2e",
        box=box.ROUNDED
    )


def make_footer(state: AppState) -> Panel:
    """Render footer with context-sensitive keybindings"""
    if state.view_mode == "logs":
        help_text = "[Enter] 返回列表  [q] 退出"
    else:
        # Show context-sensitive help with focus indicator
        selected_count = len(state.get_selected_tools())
        focus_hint = "分类" if state.focus_panel == "sidebar" else "工具"
        help_parts = [
            f"[h/l] 切换面板",
            f"[j/k] 移动({focus_hint})",
            "[Space] 选择",
            "[i] 安装当前",
        ]
        
        if selected_count > 0:
            help_parts.append(f"[a] 批量安装({selected_count})")
        else:
            help_parts.append("[a] 批量安装")
        
        help_parts.extend(["[Enter] 日志", "[q] 退出"])
        help_text = "  ".join(help_parts)
    
    return Panel(
        Text(help_text, style="white", justify="center"),
        style="white on #1e1e2e",
        box=box.ROUNDED
    )


def render_ui(state: AppState) -> Layout:
    """Render complete UI layout"""
    layout = Layout(name="root")
    
    layout.split(
        Layout(name="header", size=3),
        Layout(name="main", ratio=1),
        Layout(name="footer", size=3),
    )
    
    # Update header and footer
    layout["header"].update(make_header(state))
    layout["footer"].update(make_footer(state))
    
    # Toggle body view - different layouts for list vs logs mode
    if state.view_mode == "logs":
        # Logs mode: sidebar + full-width logs panel
        layout["main"].split_row(
            Layout(name="sidebar", size=26),
            Layout(name="body", ratio=1),
        )
        layout["sidebar"].update(make_sidebar(state))
        layout["body"].update(make_logs(state))
    else:
        # List mode: sidebar + tool list + script preview
        layout["main"].split_row(
            Layout(name="sidebar", size=26),
            Layout(name="body", ratio=1, minimum_size=40),
            Layout(name="preview", ratio=1, minimum_size=45),
        )
        layout["sidebar"].update(make_sidebar(state))
        layout["body"].update(make_tool_list(state))
        layout["preview"].update(make_preview(state))
    
    return layout


