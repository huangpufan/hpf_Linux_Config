# HPF Linux Config - TUI 安装器

基于 Rich 库构建的现代化终端 UI 安装器，支持 Vim 风格按键操作和异步并发执行。

## 功能特性

- 🎨 **现代化 TUI**: 使用 Rich 库构建，保持 `proto_modern.py` 的视觉风格
- ⌨️ **Vim 按键**: 完整的 Vim 风格导航（`hjkl`）
- ⚡ **异步执行**: 支持并发安装多个工具，实时显示日志
- 🔍 **智能检查**: 自动检测 sudo 权限、SSH 配置、WSL 环境
- 📦 **模块化**: 基于 JSON 配置文件，易于扩展

## 安装依赖

```bash
pip3 install -r requirements.txt
```

或者直接安装：

```bash
pip3 install rich
```

## 使用方法

### 启动安装器

```bash
# 方式 1: 使用快速启动脚本（推荐）
./run.sh

# 方式 2: 直接运行主程序
python3 installer_new.py

# 或者使用旧版单文件（不推荐）
python3 installer.py
```

### 按键操作

#### 导航
- `h` / `←` : 切换到前一个分类
- `l` / `→` : 切换到后一个分类  
- `j` / `↓` : 下移选择
- `k` / `↑` : 上移选择

#### 操作
- `Space` : 勾选/取消勾选当前工具
- `i` : 安装当前选中的工具
- `a` : 批量安装所有已勾选的工具
- `Enter` : 切换到日志详情视图
- `q` : 退出程序

#### 视图
- 在**列表视图**按 `Enter` 进入**日志视图**
- 在**日志视图**按 `Enter` 返回**列表视图**

## 目录结构

```
tui_workspace/
├── src/                 # 源代码模块
│   ├── __init__.py      # 包初始化
│   ├── models.py        # 数据模型 (Tool, Category, AppState)
│   ├── config.py        # 配置管理
│   ├── system.py        # 系统检查 (sudo, SSH, WSL)
│   ├── executor.py      # 任务执行引擎
│   ├── input.py         # 键盘输入处理
│   ├── ui.py            # UI 渲染组件
│   └── app.py           # 主应用逻辑
├── installer_new.py     # 主程序入口（模块化版本）
├── installer.py         # 旧版单文件入口（已废弃）
├── proto_modern.py      # 原型视觉设计
├── tools_config.json    # 工具配置文件
├── requirements.txt     # Python 依赖
├── run.sh               # 快速启动脚本
└── README.md            # 本文档

install-script/          # 实际安装脚本
├── basic/               # 基础环境脚本
├── nvim/                # Neovim 配置
└── lib/                 # 公共库
```

## 配置文件说明

`tools_config.json` 定义了所有可安装的工具和分类：

```json
{
  "categories": [
    {
      "id": "base",
      "name": "基础环境",
      "icon": "📦",
      "tools": [
        {
          "id": "apt-snap",
          "name": "系统基础包",
          "description": "Git, Tmux, Htop...",
          "script": "basic/apt-snap-install.sh",
          "requires_sudo": true,
          "check_cmd": "command -v git"
        }
      ]
    }
  ]
}
```

### 工具配置字段

- `id`: 唯一标识符
- `name`: 显示名称
- `description`: 描述信息
- `script`: 相对于 `install-script/` 的脚本路径
- `requires_sudo`: 是否需要 sudo 权限
- `requires_ssh`: 是否需要 SSH 密钥配置（可选）
- `check_cmd`: 用于检测工具是否已安装的命令（可选）

## 系统要求

- **操作系统**: Ubuntu 20.04+ / Debian-based Linux
- **Python**: 3.7+
- **终端**: 支持 ANSI 转义序列和 UTF-8
- **权限**: 大部分脚本需要 sudo 权限

### WSL 用户注意

- Snap 功能在 WSL 下可能不可用（会自动跳过）
- DNS/Hosts 相关配置建议谨慎使用

## 已知问题

1. **Sudo 密码**: 如果 sudo 会话过期，后台任务可能会卡住。建议运行前执行 `sudo -v`。
2. **SSH 密钥**: `linux-repository-install.sh` 需要 GitHub SSH 配置，未配置时会自动跳过。

## 开发

### 添加新工具

1. 编辑 `tools_config.json`，在对应分类下添加工具定义
2. 确保脚本路径正确且具有执行权限
3. 重新启动 `installer.py`

### 调试

查看实时日志输出：
- 在 TUI 中选择正在运行的任务
- 按 `Enter` 进入日志视图
- 日志会保留最近 500 行

## 许可

遵循项目根目录的许可协议。

