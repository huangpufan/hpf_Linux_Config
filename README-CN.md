# HPF Linux Config

**[English](README.md) | [中文](README-CN.md)**

> 现代化、模块化的 Linux 开发环境配置，专为 WSL2 设计，固定仓库路径，并提供 agent-first 安装流程和确定性执行入口。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-WSL2%20%7C%20Linux-green.svg)]()
[![Neovim](https://img.shields.io/badge/Editor-Neovim-brightgreen.svg)](https://neovim.io/)

## 特性

- **Agent Playbook** - 先探测、再提问、后执行、最后验证。
- **Deterministic Runner** - 使用 Python 标准库提供统一的 `list`、`check`、`install`、`preset` 入口。
- **GitHub 认证流程** - 默认 `gh + HTTPS`，只有明确需要时才切到 SSH。
- **模块化脚本** - 每个工具保留独立安装脚本，位于 `install-script/`。
- **预设组合** - 提供 `minimal`、`dev-cli`、`dev-full`、`all-tools`。
- **Neovim 配置** - 内置面向 C/C++ 开发的 Neovim 配置，并小范围使用 snacks.nvim 实用模块。

## 快速开始

仓库正式要求放在 `~/hpf_Linux_Config`。

```bash
git clone https://github.com/huangpufan/hpf_Linux_Config.git ~/hpf_Linux_Config
cd ~/hpf_Linux_Config

# 如未安装 gh，先装 GitHub CLI
python3 install-script/agent-runner.py install gh

# 配置 Git 身份
HPF_GIT_NAME="你的名字" \
HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity

# 先完成 GitHub CLI 认证，默认走 HTTPS
python3 install-script/agent-runner.py install github-auth

# 再安装基础工具集
python3 install-script/agent-runner.py preset minimal
```

## Agent 工作流

安装任务先看这些文件，按这个顺序读：

- [AGENTS.md](AGENTS.md)
- [docs/agent-install-playbook.md](docs/agent-install-playbook.md)

安装相关代码主要集中在 `install-script/`，其中：

- `install-script/presets/` 是预设组合入口
- `install-script/setup/` 是系统与账号配置
- `install-script/basic/` 是基础环境引导
- `install-script/tools/` 是单工具安装脚本
- `install-script/openharmony/` 是 OpenHarmony 专用环境脚本，不属于默认机器初始化

当前仓库的唯一工具目录是 `install-script/agent-tools.json`。安装状态只由 `check_cmd` 判定，不再维护 TUI 本地状态。runner 还会强制检查仓库是否位于 `~/hpf_Linux_Config`。

## Runner 命令

```bash
# 列出全部目录项
python3 install-script/agent-runner.py list

# 配置 Git 与 GitHub
HPF_GIT_NAME="你的名字" HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity
python3 install-script/agent-runner.py install github-auth

# 如确实需要 SSH，再显式执行
python3 install-script/agent-runner.py install github-ssh

# 验证单个工具或全量目录
python3 install-script/agent-runner.py check git
python3 install-script/agent-runner.py check all

# 按 tool id 执行
python3 install-script/agent-runner.py install git
python3 install-script/agent-runner.py install gh

# 执行预设
python3 install-script/agent-runner.py preset minimal
python3 install-script/agent-runner.py preset dev-cli
python3 install-script/agent-runner.py preset dev-full
python3 install-script/agent-runner.py preset all-tools
```

所有安装执行都会把 stdout/stderr 实时输出到终端，并写入 `~/.local/share/hpf-linux-config/logs/`。

## 项目结构

```text
hpf_Linux_Config/
├── AGENTS.md
├── docs/
│   └── agent-install-playbook.md
├── install-script/
│   ├── agent-runner.py
│   ├── agent-tools.json
│   ├── tools/
│   ├── presets/
│   ├── setup/
│   ├── basic/
│   └── lib/
├── nvim/
└── makefile
```

## 直接调用脚本

如果不走 runner，也可以直接调用原有预设脚本。
但这些 direct script 只支持仓库位于 `~/hpf_Linux_Config` 的情况：

```bash
bash install-script/presets/minimal.sh
bash install-script/presets/dev-cli.sh
bash install-script/presets/dev-full.sh
bash install-script/presets/all-tools.sh
```

## Neovim 配置

链接仓库内置的 Neovim 配置：

```bash
make link-nvim
```

Neovim 配置仍保留 Telescope、nvim-tree、alpha 和终端插件的现有主路径，仅使用 snacks.nvim 处理大文件、快速文件显示、buffer 删除、单词引用和 Lazygit。

## 环境要求

- Ubuntu 20.04/22.04/24.04（推荐 WSL2）
- Python 3.8+
- Git
- `gh` 可由本仓库通过 `install-script/tools/apt/gh.sh` 安装

## 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE)。
