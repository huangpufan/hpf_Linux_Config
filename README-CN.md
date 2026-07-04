# HPF Linux Config

**[English](README.md) | [中文](README-CN.md)**

> 现代化、模块化的 Linux 开发环境配置，专为 WSL2 设计，固定仓库路径，并提供 agent-first 安装流程和确定性执行入口。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-WSL2%20%7C%20Linux-green.svg)]()
[![Neovim](https://img.shields.io/badge/Editor-Neovim-brightgreen.svg)](https://neovim.io/)

## 特性

- **Agent Playbook** - 先探测、再提问、后执行、最后验证。
- **Deterministic Runner** - 使用 Python 标准库提供统一的 `list`、`check`、`install`、`preset` 入口。
- **GitHub 认证流程** - `github-auth` 单工具默认 `gh + HTTPS`；个人新机 `bootstrap` 默认生成/上传 SSH key 并切到 SSH。
- **模块化脚本** - 每个工具保留独立安装脚本，位于 `install-script/`。
- **预设组合** - 提供 `minimal`、`dev-cli`、`dev-full`、`all-tools`，其中 `all-tools` 表示 `bootstrap + dev-full` 默认预设链。
- **Neovim 配置** - 内置面向 C/C++ 开发的 Neovim 配置，并小范围使用 snacks.nvim 实用模块。

## 快速开始

仓库正式要求放在 `~/hpf_Linux_Config`。

```bash
git clone https://github.com/huangpufan/hpf_Linux_Config.git ~/hpf_Linux_Config
cd ~/hpf_Linux_Config

# 部署运行时配置（GNU stow）
sudo apt-get install -y stow
stow home -t $HOME

# 如未安装 gh，先装 GitHub CLI
python3 install-script/agent-runner.py install gh

# 配置 Git 身份
HPF_GIT_NAME="你的名字" \
HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity

# 先完成 GitHub CLI 认证，单工具默认走 HTTPS
python3 install-script/agent-runner.py install github-auth

# 个人新机路径会额外生成/上传 SSH key，并切到 SSH
# 当前账户是 hpf 时可直接执行；非 hpf 账户需先确认再设置 HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes 和 HPF_GIT_EMAIL
python3 install-script/agent-runner.py preset bootstrap

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

# 如只跑单工具认证且需要 SSH，再显式执行；preset bootstrap 会默认执行这一步
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
`all-tools` 是 `bootstrap + dev-full` 默认预设链，不包含 `nvim`、OpenHarmony 或个人专项脚本。
`bootstrap` / `all-tools` 会在非 `hpf` 账户上要求显式设置
`HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes` 和 `HPF_GIT_EMAIL`，避免 agent 在他人机器上静默上传 SSH key。

## 项目结构

```text
hpf_Linux_Config/
├── AGENTS.md
├── ARCHITECTURE.md
├── docs/
│   └── agent-install-playbook.md
├── home/                          # stow 根目录 — 部署：stow home -t $HOME
│   ├── .bash-aliases              #   → ~/.bash-aliases
│   ├── .bash-env                  #   → ~/.bash-env
│   ├── .bash-source               #   → ~/.bash-source
│   ├── .tmux.conf                 #   → ~/.tmux.conf
│   ├── .cargo/
│   │   └── config.toml            #   → ~/.cargo/config.toml
│   ├── .cgdb/
│   │   └── cgdbrc                 #   → ~/.cgdb/cgdbrc
│   └── .config/
│       └── herdr/
│           └── config.toml        #   → ~/.config/herdr/config.toml
├── install-script/
│   ├── agent-runner.py
│   ├── agent-tools.json
│   ├── tools/
│   ├── presets/
│   ├── setup/
│   ├── basic/
│   └── lib/
├── nvim/                          # 通过 agent-runner.py install nvim 安装/链接
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

## 使用 GNU Stow 管理运行时配置

运行时配置（shell 别名、tmux、cargo、herdr 等）统一放在 `home/` 目录下，通过 [GNU Stow](https://www.gnu.org/software/stow/) 部署到 `$HOME`。

`home/.cargo/config.toml` 有意保留 rsproxy sparse registry，作为本个人配置仓库面向国内网络的默认值。非国内网络或公司网络可删除 `[source.crates-io] replace-with` 设置，或用本机 local override 覆盖。

### 部署

```bash
cd ~/hpf_Linux_Config
stow home -t $HOME
# 或：make stow
```

### 撤销部署（移除所有符号链接）

```bash
cd ~/hpf_Linux_Config
stow -D home -t $HOME
```

### 新增配置文件

1. 将文件放到 `home/` 下对应 `$HOME` 的路径。
   - 示例：`~/.config/kitty/kitty.conf` → `home/.config/kitty/kitty.conf`
2. 提交并推送。
3. 重新部署：

```bash
stow home -t $HOME
```

Stow 会自动为 `home/` 下的新文件创建符号链接，已有文件会跳过。

## Neovim 配置

Neovim 单独管理（不走 stow），因为它位于仓库根目录。标准安装路径是 runner：

```bash
cd ~/hpf_Linux_Config
python3 install-script/agent-runner.py install nvim --dry-run
python3 install-script/agent-runner.py install nvim
python3 install-script/agent-runner.py check nvim
```

`make link-nvim` 只作为已安装环境上的 legacy/manual relink fallback；它不会安装 Neovim、provider 或插件。

Neovim 当前主路径保留 Telescope、nvim-tree、Aerial、Incline 与 toggleterm；Markdown 使用 render-markdown.nvim 作为内渲染路径，markdown-preview.nvim 作为可选浏览器预览。

## 环境要求

- Ubuntu 20.04/22.04/24.04（推荐 WSL2）
- Python 3.8+
- Git
- `gh` 可由本仓库通过 `install-script/tools/apt/gh.sh` 安装

## 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE)。
