# 源代码模块说明

本目录包含 TUI 安装器的模块化实现，遵循单一职责原则和关注点分离。

## 模块职责

### `models.py` - 数据模型
定义核心数据结构：
- `Status`: 任务状态枚举 (PENDING, RUNNING, SUCCESS, FAILED, SKIPPED)
- `Tool`: 工具/包的数据模型，包含脚本路径、状态、日志等
- `Category`: 工具分类，包含多个 Tool
- `AppState`: 全局应用状态，管理当前选择、视图模式等

### `config.py` - 配置管理
- `Config`: 加载和解析 `tools_config.json`
- 创建 Category 和 Tool 对象树
- 管理脚本根目录路径

### `system.py` - 系统检查
异步检查系统环境：
- `check_sudo()`: 检测 sudo 权限
- `check_ssh()`: 检测 GitHub SSH 密钥配置
- `check_wsl()`: 检测是否运行在 WSL 环境
- `check_system()`: 执行所有检查并更新 AppState

### `executor.py` - 任务执行引擎
异步执行安装脚本：
- `execute_tool()`: 执行单个工具安装，实时捕获日志
- `install_selected()`: 并发执行多个已选工具的安装
- 处理前置条件检查（SSH、文件存在性）
- 错误处理和状态更新

### `input.py` - 键盘输入处理
- `KeyboardInput`: 无阻塞键盘输入类（使用 termios/tty）
- `handle_input()`: Vim 风格按键绑定处理
  - `hjkl`: 导航
  - `Space`: 选择
  - `i`: 安装当前
  - `a`: 批量安装
  - `Enter`: 切换视图
  - `q`: 退出

### `ui.py` - UI 渲染
使用 Rich 库渲染各个 UI 组件：
- `make_header()`: 顶部标题栏，显示状态和时间
- `make_sidebar()`: 左侧分类导航
- `make_tool_list()`: 中间工具列表
- `make_logs()`: 日志详情面板
- `make_footer()`: 底部帮助栏，显示上下文相关的快捷键
- `render_ui()`: 组装完整的布局

### `app.py` - 主应用逻辑
- `Application`: 主应用类
- `initialize()`: 初始化配置和系统检查
- `run()`: 主事件循环，协调输入和渲染
- `show_summary()`: 显示安装总结

## 数据流

```
installer_new.py (入口)
    ↓
app.py (Application)
    ↓
config.py (加载配置) → models.py (创建数据结构)
    ↓
system.py (检查环境) → 更新 AppState
    ↓
【主循环】
input.py (获取按键) → handle_input() → executor.py (执行任务)
    ↓                                         ↓
ui.py (渲染界面) ← models.py (AppState) ← 更新状态和日志
```

## 扩展指南

### 添加新的UI组件
在 `ui.py` 中添加 `make_*()` 函数，返回 Rich 的 Panel 或其他组件。

### 添加新的按键绑定
在 `input.py` 的 `handle_input()` 中添加新的 `elif` 分支。

### 添加新的系统检查
在 `system.py` 中添加新的 `check_*()` 函数，并在 `AppState` 中添加对应字段。

### 修改任务执行逻辑
在 `executor.py` 中修改 `execute_tool()`，可以添加前置/后置钩子、重试逻辑等。

## 测试

```bash
# 运行主程序
python3 ../installer_new.py

# 或使用演示模式（不实际执行脚本）
python3 ../demo.py
```


