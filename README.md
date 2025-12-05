# My_Linux_Config

This is my personal linux config.

Mainly for windows **WSL2** ubuntu-20.04/22.04 and **neovim** as editor.

## Quick Start

```bash
# 安装 TUI 安装器
cd tui-installer && pip install -e . && cd ..

# 运行 TUI 安装器（推荐）
make run_tui_installer

# 或使用预设组合
bash install-script/presets/minimal.sh      # 最小工具集
bash install-script/presets/dev-cli.sh      # CLI 开发工具
bash install-script/presets/dev-full.sh     # 完整开发环境
```

## Project Structure

```
hpf_Linux_Config/
├── install-script/
│   ├── tools/           # 独立工具安装脚本（每个工具一个脚本）
│   │   ├── apt/         # APT 安装的工具
│   │   ├── snap/        # Snap 安装的工具
│   │   ├── cargo/       # Cargo 安装的工具
│   │   ├── npm/         # NPM 安装的工具
│   │   ├── pip/         # Pip 安装的工具
│   │   └── curl/        # 通过 curl 脚本安装的工具
│   ├── setup/           # 系统配置脚本
│   ├── presets/         # 预设安装组合
│   ├── basic/           # 原有脚本（已迁移）
│   └── lib/             # 公共函数库
├── tui-installer/       # TUI 安装器
└── nvim/                # Neovim 配置
```

## Included Tools

- **Terminal**: Bat (cat), ncdu/dust (du), Zoxide (cd), Fzf (fuzzy finder)
- **Git**: Lazygit, Git
- **File Manager**: Ranger, Yazi, Broot
- **Process**: Htop, Btop, Procs, Fkill
- **Dev**: Build-essential, GCC, Clang, XMake

## Other Configs

- Modern neovim config for C/C++ programming.
- Tmux config. 
- Ranger install script.
- Wezterm config. (Fork from github)
