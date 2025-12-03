# HPF Linux Config - TUI 安装器

基于 Rich 库构建的现代化终端 UI 安装器，支持 Vim 风格按键操作和异步并发执行。

## 功能特性

- 🎨 **现代化 TUI**: 使用 Rich 库构建精美的终端界面
- ⌨️ **Vim 按键**: 完整的 Vim 风格导航（`hjkl`）
- ⚡ **异步执行**: 支持并发安装多个工具，实时显示日志
- 🔍 **智能检查**: 自动检测 sudo 权限、SSH 配置、WSL 环境
- 📦 **模块化**: 基于 JSON 配置文件，易于扩展

## 快速开始

### 安装

```bash
# 推荐：使用 pip 安装（开发模式）
pip install -e .

# 或者只安装依赖
pip install rich
```

### 运行

```bash
# 方式 1: 使用 Make（推荐）
make run

# 方式 2: Python 模块方式
python -m tui_installer

# 方式 3: 安装后直接使用命令
tui-installer

# 方式 4: 使用快速启动脚本
./scripts/run.sh
```

## 按键操作

### 导航

| 按键 | 功能 |
|------|------|
| `h` / `←` | 切换到前一个分类 |
| `l` / `→` | 切换到后一个分类 |
| `j` / `↓` | 下移选择 |
| `k` / `↑` | 上移选择 |

### 操作

| 按键 | 功能 |
|------|------|
| `Space` | 勾选/取消勾选当前工具 |
| `i` | 安装当前选中的工具 |
| `a` | 批量安装所有已勾选的工具 |
| `Enter` | 切换到日志详情视图 |
| `q` | 退出程序 |

## 项目结构

```
tui-installer/
├── pyproject.toml           # 项目配置与依赖管理
├── Makefile                  # 常用开发命令
├── README.md                 # 本文档
├── QUICKSTART.md             # 快速入门指南
├── CHANGELOG.md              # 版本更新日志
├── tui_installer/            # 主程序包
│   ├── __init__.py           # 包初始化与版本信息
│   ├── __main__.py           # 程序入口点
│   ├── app.py                # 应用主逻辑与事件循环
│   ├── config.py             # 配置管理
│   ├── models.py             # 数据模型 (Tool, Category, AppState)
│   ├── executor.py           # 任务执行引擎
│   ├── input.py              # 键盘输入处理
│   ├── ui.py                 # UI 渲染组件
│   ├── system.py             # 系统检查 (sudo, SSH, WSL)
│   ├── py.typed              # PEP 561 类型标记
│   └── data/
│       └── tools_config.json # 工具配置文件
├── tests/                    # 测试目录
│   ├── conftest.py           # pytest 配置与 fixtures
│   ├── test_models.py        # 数据模型测试
│   └── test_config.py        # 配置管理测试
└── scripts/                  # 辅助脚本
    ├── run.sh                # 快速启动脚本
    └── test_keys.py          # 按键测试工具

../install-script/            # 实际安装脚本（项目外部）
├── basic/                    # 基础环境脚本
├── nvim/                     # Neovim 配置
└── lib/                      # 公共库
```

## 开发

### 安装开发依赖

```bash
make install-dev
# 或者
pip install -e ".[dev]"
```

### 常用命令

```bash
make help        # 查看所有可用命令
make test        # 运行测试
make lint        # 代码检查
make format      # 代码格式化
make clean       # 清理缓存文件
make build       # 构建分发包
make test-keys   # 运行按键测试工具
```

### 添加新工具

1. 编辑 `tui_installer/data/tools_config.json`，在对应分类下添加工具定义
2. 确保脚本路径正确且具有执行权限
3. 重新启动安装器

### 配置文件格式

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

#### 工具配置字段

| 字段 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | string | ✓ | 唯一标识符 |
| `name` | string | ✓ | 显示名称 |
| `description` | string | ✓ | 描述信息 |
| `script` | string | ✓ | 相对于 `install-script/` 的脚本路径 |
| `requires_sudo` | bool | | 是否需要 sudo 权限 |
| `requires_ssh` | bool | | 是否需要 SSH 密钥配置 |
| `check_cmd` | string | | 检测是否已安装的命令 |

## 系统要求

- **操作系统**: Ubuntu 20.04+ / Debian-based Linux
- **Python**: 3.8+
- **终端**: 支持 ANSI 转义序列和 UTF-8
- **权限**: 大部分脚本需要 sudo 权限

### WSL 用户注意

- Snap 功能在 WSL 下可能不可用（会自动跳过）
- DNS/Hosts 相关配置建议谨慎使用

## 已知问题

1. **Sudo 密码**: 如果 sudo 会话过期，后台任务可能会卡住。建议运行前执行 `sudo -v`
2. **SSH 密钥**: 部分脚本需要 GitHub SSH 配置，未配置时会自动跳过

## 许可证

MIT License
