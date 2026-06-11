# 仓库身份

本仓库 `hpf_Linux_Config` 是一个面向 Linux / WSL2 开发机初始化的配置仓库，目标是把常用开发工具、Git/GitHub 配置、shell 环境和 Neovim 配置组织成一套可重复执行的安装体系。它不是服务端应用，也不是通用部署平台。

## 核心定位

| 字段 | 内容 | 证据 |
|---|---|---|
| 仓库名称 | `hpf_Linux_Config` | 根 README |
| 主要用途 | Linux / WSL2 开发环境初始化与配置 | `README-CN.md` |
| 运行方式 | 以 `install-script/agent-runner.py` 为统一入口执行本地脚本 | AGENTS、playbook |
| 支持平台 | Ubuntu 20.04 / 22.04 / 24.04，推荐 WSL2 | README、playbook |
| 主要交付物 | 安装脚本、dotfiles、Neovim 配置 | 根目录结构 |

## 读者提示

- 若任务涉及安装环境、检查状态或新增工具，先回到 [架构主干](../architecture/README.md)。
- 若只是看编辑器配置，可把 `nvim/` 视为支线子树，而不是仓库主架构入口。
