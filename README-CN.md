# HPF Linux Config

**[English](README.md) | [中文](README-CN.md)**

> 现代化、模块化的 Linux 开发环境配置，专为 WSL2 设计，包含 TUI 安装器和精选 CLI 工具集。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-WSL2%20%7C%20Linux-green.svg)]()
[![Neovim](https://img.shields.io/badge/Editor-Neovim-brightgreen.svg)](https://neovim.io/)

## 特性

- **TUI 安装器** - 支持 Vim 风格按键的交互式终端界面，轻松安装工具
- **模块化设计** - 每个工具独立安装脚本，易于扩展和维护
- **预设配置** - 针对不同使用场景的预定义工具组合
- **现代 CLI 工具** - 精选的传统 Unix 工具现代替代品
- **Neovim 配置** - 针对 C/C++ 开发优化，支持 LSP

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/huangpufan/hpf_Linux_Config.git
cd hpf_Linux_Config

# 安装 TUI 安装器依赖
cd tui-installer && pip install -e . && cd ..

# 运行 TUI 安装器（推荐）
make run_tui_installer
```

### 使用预设

```bash
# 最小工具集 - 仅必要工具
bash install-script/presets/minimal.sh

# CLI 开发工具
bash install-script/presets/dev-cli.sh

# 完整开发环境
bash install-script/presets/dev-full.sh
```

## 项目结构

```
hpf_Linux_Config/
├── install-script/
│   ├── tools/           # 独立工具安装脚本
│   │   ├── apt/         # APT 包
│   │   ├── snap/        # Snap 包
│   │   ├── cargo/       # Rust/Cargo 工具
│   │   ├── npm/         # Node.js 包
│   │   ├── pip/         # Python 包
│   │   └── curl/        # 通过 curl 安装的工具
│   ├── setup/           # 系统配置脚本
│   ├── presets/         # 预设安装组合
│   ├── basic/           # 基础配置（tmux、zsh 等）
│   └── lib/             # 公共工具函数
├── tui-installer/       # TUI 安装器应用
│   └── tui_installer/   # Python 包源码
├── nvim/                # Neovim 配置
└── makefile             # 项目快捷命令
```

## 工具列表

### 终端增强

| 工具 | 替代 | 描述 |
|------|------|------|
| [bat](https://github.com/sharkdp/bat) | `cat` | 语法高亮和 Git 集成 |
| [eza](https://github.com/eza-community/eza) | `ls` | 现代文件列表，支持图标 |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` | 更智能的目录导航 |
| [fzf](https://github.com/junegunn/fzf) | - | 万能模糊搜索器 |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` | 快速递归搜索 |
| [fd](https://github.com/sharkdp/fd) | `find` | 用户友好的文件查找器 |

### 文件管理器

| 工具 | 描述 |
|------|------|
| [yazi](https://github.com/sxyazi/yazi) | 极速终端文件管理器 |
| [broot](https://github.com/Canop/broot) | 带模糊搜索的树形视图 |
| [ranger](https://github.com/ranger/ranger) | Vim 风格文件管理器 |

### 系统监控

| 工具 | 替代 | 描述 |
|------|------|------|
| [btop](https://github.com/aristocratos/btop) | `top`/`htop` | 带图表的资源监视器 |
| [dust](https://github.com/bootandy/dust) | `du` | 直观的磁盘使用分析 |
| [procs](https://github.com/dalance/procs) | `ps` | 现代进程查看器 |

### 开发工具

| 工具 | 描述 |
|------|------|
| [lazygit](https://github.com/jesseduffield/lazygit) | Git 终端界面 |
| [delta](https://github.com/dandavison/delta) | 美观的 Git diff |
| [xmake](https://github.com/xmake-io/xmake) | 跨平台构建工具 |

## TUI 安装器

TUI 安装器提供交互式界面，用于选择和安装工具。

### 按键操作

| 按键 | 功能 |
|------|------|
| `h`/`l` | 切换分类 |
| `j`/`k` | 上下导航 |
| `Space` | 切换选择 |
| `Enter` | 安装选中项 |
| `a` | 全选 |
| `n` | 取消全选 |
| `q` | 退出 |

## Neovim 配置

针对 C/C++ 开发优化：

- **LSP**: clangd、lua-language-server
- **补全**: nvim-cmp + snippets
- **模糊搜索**: Telescope
- **文件浏览**: nvim-tree
- **Git 集成**: gitsigns、fugitive

```bash
# 链接 neovim 配置
make link-nvim
```

## Tmux 配置

预配置的 tmux：

- Vim 风格窗格导航（`Ctrl+hjkl`）
- 便捷窗格调整（`prefix + HJKL`）
- TPM 插件管理器
- Dracula 主题

## 环境要求

- Ubuntu 20.04/22.04（推荐 WSL2）
- Python 3.8+
- Git

## 贡献

欢迎贡献！请随时提交 Pull Request。

1. Fork 本仓库
2. 创建特性分支（`git checkout -b feature/amazing-feature`）
3. 提交更改（`git commit -m 'Add amazing feature'`）
4. 推送到分支（`git push origin feature/amazing-feature`）
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 致谢

- 所有优秀的开源工具作者
- Neovim 社区
- [Rich](https://github.com/Textualize/rich) 库提供的精美 TUI
